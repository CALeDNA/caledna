# frozen_string_literal: true

# used for api/v1/samples, api/v1/field_projects
module FilterSamples
  extend self

  include CheckWebsite

  private

  # ====================
  # common
  # ====================

  def conn
    @conn ||= ActiveRecord::Base.connection
  end

  def website_sample
    @website_sample ||= CheckWebsite.caledna_site? ? Sample : Sample.la_river
  end

  def website_sample_map
    @website_sample_map ||= begin
      if CheckWebsite.caledna_site?
        SamplesMap
      else
        SamplesMap.where(field_project_id: FieldProject.la_river.ids)
      end
    end
  end

  # ====================
  # samples_map
  # ====================

  def base_samples_columns
    %w[
      id latitude longitude barcode status substrate location collection_date
      taxa_count
    ]
  end

  def samples_columns
    base_samples_columns + %w[primer_ids primer_names]
  end

  def samples_primers_columns
    'array_agg(distinct primers.id) as primer_ids, ' \
    'array_agg(distinct primers.name) as primer_names'
  end

  def samples_for_primers(samples)
    primer_ids = params[:primer].tr('|', ',')

    samples.where('primer_ids && ?', "{#{primer_ids}}")
  end

  def completed_samples_for_primers(samples)
    primer_ids = params[:primer].split('|')

    samples.where('primers.id IN (?)', primer_ids)
  end

  def published_samples_sql
    <<~SQL
      samples_map.id NOT IN (
        SELECT sample_id
        FROM sample_primers
        JOIN research_projects
          ON research_projects.id = sample_primers.research_project_id
          AND research_projects.published = false
       )
    SQL
  end

  def base_samples_for_map
    @base_samples_for_map ||= website_sample_map.where(published_samples_sql)
  end

  # ====================
  # approved_samples: Samples#index map, FieldProject#show map
  # ====================

  def approved_completed_samples
    samples = base_samples_for_map.where(approved_completed_query_string)
                                  .select(samples_columns)

    samples = samples_for_primers(samples) if params[:primer]
    samples
  end

  def approved_completed_query_string
    query = {}
    query[:status] = params[:status] if params[:status]
    query[:substrate] = params[:substrate].split('|') if params[:substrate]
    query
  end

  # ====================
  # completed_samples: Taxa#show map, ResearchProject#show map
  # ====================

  def completed_samples
    @completed_samples ||= begin
      samples = base_samples_for_map
                .select(base_samples_columns)
                .select(samples_primers_columns)
                .where(status: :results_completed)
                .where(completed_query_string)
                .group(base_samples_columns)

      samples = completed_samples_for_primers(samples) if params[:primer]
      samples
    end
  end

  def basic_completed_samples
    columns = %w[id latitude longitude substrate primer_ids barcode status]
    samples = base_samples_for_map.select(columns)
                                  .where(status: :results_completed)
                                  .where(completed_query_string)

    samples = samples_for_primers(samples) if params[:primer]
    samples
  end

  def completed_query_string
    query = {}
    query[:substrate] = params[:substrate].split('|') if params[:substrate]
    query
  end

  # ====================
  # hero counts
  # ====================

  public def approved_samples_count
    @approved_samples_count ||= begin
      base_samples_for_map.count
    end
  end

  public def completed_samples_count
    @completed_samples_count ||= begin
      base_samples_for_map
        .where(status: :results_completed)
        .count
    end
  end
end
