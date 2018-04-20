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

  # rubocop:disable Metrics/MethodLength
  def raw_samples
    # https://stackoverflow.com/a/36251296
    # Query postgres jsonb by value

    sql = 'SELECT samples.id, samples.barcode, ' \
    'asvs."taxonID" as "taxonID", taxa."canonicalName", samples.latitude, ' \
    'samples.longitude, field_data_project_id, ' \
    'field_data_projects.name as field_data_project_name ' \
    'FROM asvs ' \
    'INNER JOIN taxa ON asvs."taxonID" = taxa."taxonID" ' \
    'INNER JOIN extractions ON asvs.extraction_id = extractions.id ' \
    'INNER JOIN samples ON samples.id = extractions.sample_id ' \
    'INNER JOIN field_data_projects ON samples.field_data_project_id ' \
    ' = field_data_projects.id ' \
    'where exists (select 1 from jsonb_each_text(taxa.hierarchy) ' \
    "pair where pair.value = '#{params[:id]}');"

    @raw_samples ||= ActiveRecord::Base.connection.execute(sql)
  end
  # rubocop:enable Metrics/MethodLength

  def samples
    groups = raw_samples.group_by { |t| t['id'] }.values
    @samples ||= groups.map do |g|
      OpenStruct.new(g.first.merge(taxons: g.pluck('canonicalName', 'taxonID')))
    end
  end

  def query_string
    query = {}
    project_id = params[:field_data_project_id]
    query[:field_data_project_id] = project_id if project_id
    query
  end
end
