# frozen_string_literal: true

module ImportPlaces
  def import_shapefile(file_path, options = {})
    RGeo::Shapefile::Reader.open(file_path, srid: Geospatial::SRID) do |file|
      file_name = File.basename(file_path)
      place_source = find_place_source(file_name, options)
      options[:place_source_id] = place_source.id

      file.each do |shape|
        new_place = build_new_place(shape, options)
        existing = find_existing_place(file_name, new_place)
        new_place.save if existing.blank?
      end
    end
  end

  private

  def find_existing_place(file_name, new_place)
    Place.joins(:place_source).where(name: new_place.name)
         .where('place_sources.file_name = ?', file_name)
  end

  def build_new_place(shape, options)
    case options[:place_source_type]
    when 'census'
      new_place_from_census(shape, options)
    when 'LA_zip_code'
      new_place_from_zip_code(shape, options)
    when 'USGS'
      new_place_from_watershed(shape, options)
    when 'LA_river'
      new_place_from_la_river(shape, options)
    when 'UCNRS'
      new_place_from_ucnrs(shape, options)
    else
      new_from_shape(shape, options)
    end
  end

  def find_place_source(file_name, options)
    PlaceSource.where(
      file_name: file_name,
      place_source_type_cd: options[:place_source_type]
    ).first_or_create
  end

  def new_place_from_census(shape, options)
    data = shape.respond_to?(:data) ? shape.data : shape.attributes
    options[:name] = if options[:place_type] == 'county'
                       data['NAMELSAD']
                     else
                       data['NAME']
                     end
    options[:state_fips] = data['STATEFP']
    options[:county_fips] = data['COUNTYFP']
    options[:place_fips] = data['PLACEFP']
    options[:lsad] = data['LSAD']

    new_from_shape(shape, options)
  end

  def new_place_from_zip_code(shape, options)
    data = shape.respond_to?(:data) ? shape.data : shape.attributes
    options[:name] = data['zipcode']

    new_from_shape(shape, options)
  end

  def new_place_from_watershed(shape, options)
    data = shape.respond_to?(:data) ? shape.data : shape.attributes
    options[:name] = data['Name']
    options[:huc8] = data['HUC8']

    new_from_shape(shape, options)
  end

  def new_place_from_la_river(shape, options)
    data = shape.respond_to?(:data) ? shape.data : shape.attributes
    options[:name] = data['GNIS_NAME']
    options[:gnis_id] = data['GNIS_ID']

    new_from_shape(shape, options)
  end

  def new_place_from_ucnrs(shape, options)
    data = shape.respond_to?(:data) ? shape.data : shape.attributes
    options[:name] = data['Name']
    options[:uc_campus] = data['Campus']
    county = Place.where(name: data['County'])
                  .where(place_type_cd: 'county').first
    options[:county_fips] = county.county_fips if county.present?

    new_from_shape(shape, options)
  end

  def new_from_shape(shape, options = {})
    data = shape.respond_to?(:data) ? shape.data : shape.attributes
    name_column = options[:name_column] || 'name'
    name = options[:name] || data[name_column] || data[name_column.upcase] ||
           data[name_column.capitalize] || data[name_column.downcase]

    envel = shape.geometry.envelope
    center = envel.respond_to?(:center) ? envel : envel.centroid

    attributes = options.merge(
      name: name,
      latitude: center.y,
      longitude: center.x,
      geom: shape.geometry
    )
    Place.new(attributes)
  end
end

