# frozen_string_literal: true

class ResearchProjectsController < ApplicationController
  include PaginatedSamples

  def index
    @projects = ResearchProject.order(:name).page params[:page]
  end

  def show
    # @taxa = Taxon.where(taxonID: taxon_ids).order(:taxonRank, :canonicalName)
    @taxa = []
    @samples = paginated_samples
    @project = ResearchProject.find(params[:id])
  end

  private

  def samples
    Sample.includes(:field_data_project).approved.order(:barcode)
          .where(id: sample_ids)
  end

  def sample_ids
    sql = 'SELECT sample_id ' \
      'FROM extractions ' \
      'JOIN research_project_extractions ' \
      'ON extractions.id = research_project_extractions.extraction_id ' \
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
