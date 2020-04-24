# frozen_string_literal: true

module FilterSamples
  extend ActiveSupport::Concern

  private

  def approved_samples
    @approved_samples ||= begin
      samples = Sample.approved.with_coordinates.order(:created_at)
                      .where(query_string)

      samples = samples_for_primers(samples) if params[:primer]
      samples
    end
  end

  def samples_for_primers(samples)
    primer_ids = params[:primer].split('|')
    samples.joins(:sample_primers)
           .where('sample_primers.primer_id IN (?)', primer_ids)
           .group(:id)
  end

  def query_string
    query = {}
    query[:status_cd] = params[:status] if params[:status]
    query[:substrate_cd] = params[:substrate].split('|') if params[:substrate]
    query
  end
end
