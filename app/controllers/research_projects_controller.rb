# frozen_string_literal: true

class ResearchProjectsController < ApplicationController
  include PaginatedSamples
  include BatchData

  def index
    @projects = Kaminari.paginate_array(projects.to_a).page(params[:page])
  end

  def show
    # @taxa = Taxon.where(taxonID: taxon_ids).order(:taxonRank, :canonicalName)
    @taxa = []
    @samples = paginated_samples
    @project = ResearchProject.includes(extractions: :sample).find(params[:id])
    @asvs_count = asvs_count
  end

  private

  # rubocop:disable Metrics/MethodLength
  def projects
    # NOTE: this query provides the samples count per project
    sql = 'SELECT research_projects.id, research_projects.name, ' \
    'COUNT(DISTINCT(samples.id)) ' \
    'FROM research_projects ' \
    'LEFT JOIN research_project_extractions ' \
    'ON research_projects.id = ' \
    'research_project_extractions.research_project_id ' \
    'LEFT JOIN samples ' \
    'ON research_project_extractions.sample_id = samples.id ' \
    "WHERE samples.status_cd != 'processed_invalid_sample' "

    unless current_researcher.present?
      sql += 'AND research_projects.published = true ' \
    end

    sql += 'GROUP BY research_projects.id ' \
    'ORDER BY research_projects.name;'

    @projects ||= ActiveRecord::Base.connection.execute(sql)
  end
  # rubocop:enable Metrics/MethodLength

  def samples
    Sample.includes(:field_data_project).approved.order(:barcode)
          .where(id: sample_ids)
  end

  def sample_ids
    sql = 'SELECT sample_id ' \
      'FROM research_project_extractions ' \
      'JOIN samples ' \
      'ON samples.id = research_project_extractions.sample_id ' \
      "WHERE research_project_extractions.research_project_id = #{params[:id]};"

    @sample_ids ||= ActiveRecord::Base.connection.execute(sql)
                                      .pluck('sample_id')
  end

  def extraction_ids
    @extraction_ids ||= ResearchProjectExtraction
                        .where(research_project_id: params[:id])
                        .pluck(:extraction_id)
  end

  def taxon_ids
    @taxon_ids ||= Asv.where(extraction_id: extraction_ids)
                      .select(:taxonID)
                      .uniq.map(&:taxonID)
  end

  def query_string
    query = {}
    query[:status_cd] = params[:status] if params[:status]
    query
  end
end
