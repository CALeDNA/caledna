# frozen_string_literal: true

class TaxaController < ApplicationController
  include CustomPagination

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
    @ordered_taxa ||= NcbiNode.includes(:ncbi_names)
                              .where('asvs_count > 0')
                              .order(asvs_count: :desc)
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
    params[:view] ? raw_samples : []
  end

  def samples
    @samples ||= raw_samples.map { |r| OpenStruct.new(r) }
  end

  def raw_samples
    sql = <<-SQL
      SELECT DISTINCT samples.id, samples.barcode, status_cd AS status,
      samples.latitude, samples.longitude,
      array_agg(ncbi_nodes.canonical_name) AS taxa
      FROM asvs
      JOIN ncbi_nodes ON asvs."taxonID" = ncbi_nodes."taxon_id"
      JOIN samples ON samples.id = asvs.sample_id
      WHERE samples.missing_coordinates = false
    SQL
    sql += " AND ids @> '{#{conn.quote(id)}}' " \
    'GROUP BY samples.id ' \
    "LIMIT #{limit} OFFSET #{offset};"

    raw_records = conn.exec_query(sql)
    records = raw_records.map { |r| OpenStruct.new(r) }

    add_pagination_methods(records)
    records
  end

  def count_sql
    sql = <<-SQL
      SELECT count(DISTINCT(samples.id))
      FROM asvs
      JOIN ncbi_nodes ON asvs."taxonID" = ncbi_nodes."taxon_id"
      JOIN samples ON samples.id = asvs.sample_id
      WHERE samples.missing_coordinates = false
    SQL
    sql += "AND ids @> '{#{conn.quote(id)}}'"
  end

  def conn
    @conn ||= ActiveRecord::Base.connection
  end

  def id
    params[:id].to_i
  end

  def query_string
    query = {}
    project_id = params[:field_data_project_id]
    query[:field_data_project_id] = project_id if project_id
    query
  end
end
