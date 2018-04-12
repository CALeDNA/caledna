# frozen_string_literal: true

class TaxaController < ApplicationController
  def index
    # TODO: r-enable highlights
    # @highlights = Highlight.asv
    @highlights = []
    @top_taxa = Taxon.includes(:vernaculars)
                     .order(asvs_count: :desc)
                     .limit(20)
                     .sort_by do |t|
                       [
                         -t.asvs_count,
                         t.kingdom, t.phylum, t.className, t.order, t.family,
                         t.genus, t.specificEpithet, t.infraspecificEpithet
                       ].compact
                     end
  end

  def show
    @taxon = taxon
    @samples = paginated_samples
  end

  private

  def taxon
    @taxon ||= Taxon.includes(:vernaculars, :taxa_dataset).find(params[:id])
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
    @raw_samples ||= ActiveRecord::Base.connection.execute(sql)
  end

  def samples
    groups = raw_samples.group_by { |t| t['id'] }.values
    @samples ||= groups.map do |g|
      OpenStruct.new(g.first.merge(taxons: g.pluck('canonicalName', 'taxonID')))
    end
  end

  def sql_select
    'SELECT samples.id, samples.barcode, ' \
    'asvs."taxonID" as "taxonID", taxa."canonicalName", samples.latitude, ' \
    'samples.longitude, field_data_project_id, ' \
    'field_data_projects.name as field_data_project_name ' \
    'FROM asvs ' \
    'INNER JOIN taxa ON asvs."taxonID" = taxa."taxonID" ' \
    'INNER JOIN extractions ON asvs.extraction_id = extractions.id ' \
    'INNER JOIN samples ON samples.id = extractions.sample_id ' \
    'INNER JOIN field_data_projects ON samples.field_data_project_id ' \
    ' = field_data_projects.id '
  end

  def sql_where
    # https://stackoverflow.com/a/36251296
    # Query postgres jsonb by value

    'WHERE samples.latitude is NOT NULL AND samples.longitude IS NOT NULL ' \
    'AND exists (select 1 from jsonb_each_text(taxa.hierarchy) ' \
    "pair where pair.value = '#{params[:id]}');"

    # "where taxa.\"taxonID\" = #{params[:id]}"
  end

  def query_string
    query = {}
    project_id = params[:field_data_project_id]
    query[:field_data_project_id] = project_id if project_id
    query
  end
end
