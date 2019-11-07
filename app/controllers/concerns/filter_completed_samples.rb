# frozen_string_literal: true

module FilterCompletedSamples
  extend ActiveSupport::Concern

  private

  def completed_samples
    @completed_samples ||= begin
      samples = Sample.results_completed.where(query_string)

      samples = samples_for_primers(samples) if params[:primer]
      samples
    end
  end

  def samples_for_primers(samples)
    primers = Primer.all.pluck(:name)
    raw_primers = params[:primer].split('|')
                                 .select { |p| primers.include?(p) }

    samples =
      samples.where('samples.primers && ?', "{#{raw_primers.join(',')}}")
    samples
  end

  def research_project_samples
    @research_project_samples ||= begin
      completed_samples
        .joins('JOIN research_project_sources ' \
          'ON samples.id = research_project_sources.sample_id')
        .where('research_project_sources.research_project_id = ?',
               project.id)
    end
  end

  def project
    @project ||= ResearchProject.find_by(slug: params[:id])
  end

  def query_string
    query = {}
    query[:substrate_cd] = params[:substrate].split('|') if params[:substrate]
    query
  end
end
