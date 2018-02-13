# frozen_string_literal: true

class TaxaController < ApplicationController
  def index
    @higlights = TaxonomicUnit.where(highlight: true).order(:complete_name)
    @top_taxa = TaxonomicUnit.where(tsn: top_taxa_ids)
  end

  def show
    @taxon = TaxonomicUnit.find(params[:id])
    @samples = paginated_samples
    @taxa = taxa
  end

  private

  def paginated_samples
    if params[:view]
      Kaminari.paginate_array(samples).page(params[:page])
    else
      samples
    end
  end

  # rubocop:disable Metrics/MethodLength
  def raw_samples
    sql = 'SELECT samples.id, barcode, ' \
    'taxonomic_units.rank_id,  taxonomic_units.tsn as tsn, latitude, ' \
    'longitude, complete_name, field_data_project_id, name as project_name ' \
    'FROM taxonomic_units ' \
    'INNER JOIN hierarchy ON hierarchy.tsn = taxonomic_units.tsn ' \
    'INNER JOIN asvs ON hierarchy.tsn = asvs.tsn ' \
    'INNER JOIN extractions ON asvs.extraction_id = extractions.id ' \
    'INNER JOIN samples ON samples.id = extractions.sample_id ' \
    'INNER JOIN field_data_projects ON samples.field_data_project_id ' \
    ' = field_data_projects.id ' \
    'WHERE hierarchy_string ~ ' \
    "'([^[:digit:]]|^)#{params[:id]}([^[:digit:]]|$)'"

    @raw_samples ||= ActiveRecord::Base.connection.execute(sql)
  end
  # rubocop:enable Metrics/MethodLength

  def samples
    groups = raw_samples.group_by { |t| t['id'] }.values
    @samples ||= groups.map do |g|
      OpenStruct.new(g.first.merge(taxons: g.pluck('complete_name', 'tsn')))
    end
  end

  def taxa
    @taxa ||=
      TaxonomicUnit
      .distinct(:tsn)
      .joins(:hierarchy)
      .joins('INNER JOIN asvs ON hierarchy.tsn = asvs.tsn')
      .joins('INNER JOIN samples ON samples.id = asvs.sample_id')
      .where('hierarchy_string LIKE ?', "%#{params[:id]}%")
  end

  def top_taxa_ids
    Asv.group('tsn').order('count(*) DESC').limit(10).pluck(:tsn)
  end

  def query_string
    query = {}
    project_id = params[:field_data_project_id]
    query[:field_data_project_id] = project_id if project_id
    query
  end
end
