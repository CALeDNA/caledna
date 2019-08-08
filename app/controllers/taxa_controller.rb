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
    @samples = samples
  end

  private

  #================
  # index
  #================

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

  def top_taxa
    @top_taxa ||= ordered_taxa
  end

  def top_plant_taxa
    @top_plant_taxa ||= begin
      division = NcbiDivision.find_by(name: 'Plantae')
      return [] if division.blank?

      ordered_taxa.where(cal_division_id: division.id)
                  .where("hierarchy_names ->> 'phylum' = 'Streptophyta'")
    end
  end

  def top_animal_taxa
    @top_animal_taxa ||= begin
      division = NcbiDivision.find_by(name: 'Animalia')
      return [] if division.blank?

      ordered_taxa.where(cal_division_id: division.id)
                  .where("hierarchy_names ->> 'kingdom' = 'Metazoa'")
    end
  end

  def ordered_taxa
    @ordered_taxa ||= begin
      NcbiNode.order(asvs_count: :desc)
              .limit(10)
              .where(rank: :species)
              .where('taxon_id IN (SELECT asvs."taxonID" FROM asvs)')
    end
  end

  #================
  # show
  #================

  def taxon
    @taxon ||= NcbiNode.includes(:ncbi_names, :ncbi_division).find(params[:id])
  end

  def samples
    if params[:view]
      paginated_samples
    else
      OpenStruct.new(total_records: total_records)
    end
  end

  def select_sql
    <<-SQL
      SELECT samples.id, samples.barcode, status_cd AS status,
      samples.latitude, samples.longitude,
      array_agg(ncbi_nodes.canonical_name || ' | ' || ncbi_nodes.taxon_id)
      AS taxa
      FROM asvs
      JOIN ncbi_nodes ON asvs."taxonID" = ncbi_nodes."taxon_id"
      JOIN samples ON samples.id = asvs.sample_id
    SQL
  end

  def paginated_samples
    sql = select_sql
    sql += " WHERE ids @> '{#{conn.quote(id)}}' " \
      'GROUP BY samples.id ' \
      "LIMIT #{limit} OFFSET #{offset};"

    raw_records = conn.exec_query(sql)
    records = raw_records.map { |r| OpenStruct.new(r) }

    add_pagination_methods(records)
    records
  end

  def total_records
    @total_records ||= begin
      NcbiNode.find_by(taxon_id: id).asvs_count
    end
  end

  def conn
    @conn ||= ActiveRecord::Base.connection
  end

  def id
    params[:id].to_i
  end

  def query_string
    {}
  end
end
