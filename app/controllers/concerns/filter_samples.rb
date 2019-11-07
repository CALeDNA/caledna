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
    primers = Primer.all.pluck(:name)
    raw_primers = params[:primer].split('|')
                                 .select { |p| primers.include?(p) }

    samples = samples.where('primers && ?', "{#{raw_primers.join(',')}}")
    samples
  end

  def query_string
    query = {}
    query[:status_cd] = params[:status] if params[:status]
    query[:substrate_cd] = params[:substrate].split('|') if params[:substrate]
    query
  end
end
