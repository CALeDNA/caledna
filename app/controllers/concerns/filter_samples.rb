# frozen_string_literal: true

# used for api/v1/samples, api/v1/field_projects
module FilterSamples
  extend ActiveSupport::Concern
  include CheckWebsite

  private

  def website_sample
    CheckWebsite.caledna_site? ? Sample : Sample.la_river
  end

  def approved_samples
    @approved_samples ||= begin
      samples = website_sample.approved.with_coordinates.order(:created_at)
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
