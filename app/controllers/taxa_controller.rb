# frozen_string_literal: true

class TaxaController < ApplicationController
  def index
    # TODO: r-enable highlights
    # @highlights = Highlight.asv
    @highlights = []
    @top_taxa = top_taxa
    @top_plant_taxa = top_plant_taxa
    @top_animal_taxa = top_animal_taxa
    @batch_vernaculars = batch_vernaculars
  end

  def show
    @taxon = taxon
    @samples = paginated_samples
    @asvs_count = asvs_count
  end

  private

  def batch_vernaculars
    return [] if taxon_ids.blank?

    sql = 'SELECT ncbi_names.taxon_id, ncbi_names.name ' \
    'FROM ncbi_names ' \
    "WHERE taxon_id IN (#{taxon_ids.to_s[1..-2]}) " \
    "AND (name_class = 'common name' OR name_class = 'genbank common name')"

    @batch_vernaculars ||= ActiveRecord::Base.connection.execute(sql)
  end

  def taxon_ids
    top_taxa.pluck('taxon_id') +
      top_plant_taxa.pluck('taxon_id') +
      top_animal_taxa.pluck('taxon_id')
  end

  def asvs_count
    sql = 'SELECT sample_id, COUNT(*) ' \
          'FROM asvs ' \
          "WHERE \"taxonID\" = #{params[:id]} " \
          'GROUP BY sample_id '
    @asvs_count ||= ActiveRecord::Base.connection.execute(sql)
  end

  def top_taxa
    @top_taxa ||= ordered_taxa.sort_by { |t| sort_taxa_fields(t) }
  end

  def top_plant_taxa
    division = NcbiDivision.find_by(name: 'Plants')
    return [] if division.blank?
    @top_plant_taxa ||= ordered_taxa.where(cal_division_id: division.id)
                                    .sort_by { |t| sort_taxa_fields(t) }
  end

  def top_animal_taxa
    division = NcbiDivision.find_by(name: 'Animals')
    return [] if division.blank?
    @top_animal_taxa ||= ordered_taxa.where(cal_division_id: division.id)
                                     .sort_by { |t| sort_taxa_fields(t) }
  end

  def taxon
    @taxon ||= NcbiNode.includes(:ncbi_names, :ncbi_division).find(params[:id])
  end

  def ordered_taxa
    @ordered_taxa ||= NcbiNode.includes(:ncbi_names).order(asvs_count: :desc)
                              .limit(10)
  end

  def sort_taxa_fields(taxon)
    [
      -taxon.asvs_count,
      taxon.kingdom, taxon.phylum, taxon.className, taxon.order, taxon.family,
      taxon.genus, taxon.species
    ].compact
  end

  def paginated_samples
    if params[:view]
      Kaminari.paginate_array(samples).page(params[:page])
    else
      samples
    end
  end

  def raw_samples
    sql = sql_select + sql_where
    @raw_samples ||= conn.exec_query(sql)
  end

  def samples
    @samples ||= raw_samples.map { |r| OpenStruct.new(r) }
  end

  def conn
    @conn ||= ActiveRecord::Base.connection
  end

  def sql_select
    'SELECT DISTINCT samples.id, samples.barcode, status_cd as status, ' \
    'samples.latitude, samples.longitude, field_data_project_id, ' \
    'field_data_projects.name as field_data_project_name ' \
    'FROM asvs ' \
    'JOIN ncbi_nodes ON asvs."taxonID" = ncbi_nodes."taxon_id" ' \
    'JOIN samples ON samples.id = asvs.sample_id ' \
    'JOIN field_data_projects ON samples.field_data_project_id ' \
    ' = field_data_projects.id '
  end

  def sql_where
    id = params[:id].to_i
    'WHERE samples.missing_coordinates = false ' \
    "AND ids @> '{#{conn.quote(id)}}' " \
  end

  def query_string
    query = {}
    project_id = params[:field_data_project_id]
    query[:field_data_project_id] = project_id if project_id
    query
  end
end
