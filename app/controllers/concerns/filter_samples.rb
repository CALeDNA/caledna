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
    CheckWebsite.caledna_site? ? Sample : Sample.la_river
  end

  def website_asv
    CheckWebsite.caledna_site? ? Asv : Asv.la_river
  end

  def sample_columns
    %i[
      id latitude longitude barcode status_cd substrate_cd
      location collection_date
    ]
  end
  module_function :sample_columns

  def primer_names_sql
    <<~SQL.chomp
      ARRAY_AGG(DISTINCT(primers.name)) FILTER (WHERE primers.name IS NOT NULL)
      AS primer_names
    SQL
  end

  def primer_ids_sql
    <<~SQL.chomp
      ARRAY_AGG(DISTINCT(primers.id)) FILTER (WHERE primers.id IS NOT NULL)
      AS primer_ids
    SQL
  end

  def results_left_join_sql
    <<~SQL.chomp
      LEFT JOIN asvs ON asvs.sample_id = samples.id
      LEFT JOIN primers ON primers.id = asvs.primer_id
    SQL
  end

  def sample_primers_sql
    <<~SQL.chomp
      JOIN sample_primers ON sample_primers.sample_id = asvs.sample_id
      AND sample_primers.primer_id = asvs.primer_id
      AND sample_primers.research_project_id = asvs.research_project_id
    SQL
  end

  def published_research_project_sql
    <<~SQL.chomp
      JOIN research_projects
        ON asvs.research_project_id = research_projects.id
        AND research_projects.published = TRUE
    SQL
  end

  def optional_published_research_project_sql
    "LEFT #{published_research_project_sql}"
  end

  def conditional_status_sql
    <<~SQL.chomp
      CASE
        WHEN research_projects.published IS NULL THEN status_cd = 'approved'
        ELSE status_cd = 'results_completed'
        END
    SQL
  end

  def samples_for_primers(samples)
    primer_ids = params[:primer].split('|')

    samples
      .joins(sample_primers_sql)
      .where('sample_primers.primer_id IN (?)', primer_ids.map(&:to_i))
  end

  def base_samples
    website_sample
      .select(sample_columns)
      .select(primer_names_sql)
      .select(primer_ids_sql)
      .select('COUNT(DISTINCT asvs.taxon_id) as taxa_count')
      .joins(results_left_join_sql)
      .order(:created_at)
      .group(:id)
  end

  # ====================
  # approved_samples: Samples#index map, FieldProject#show map
  # ====================

  def approved_samples
    @approved_samples ||= begin
      samples = base_samples.joins(optional_published_research_project_sql)
                            .where(approved_query_string)
                            .where(conditional_status_sql)

      samples = samples_for_primers(samples) if params[:primer]
      samples
    end
  end

  def approved_query_string
    query = {}
    query[:status_cd] = params[:status] if params[:status]
    query[:substrate_cd] = params[:substrate].split('|') if params[:substrate]
    query
  end

  # ====================
  # completed_samples: Taxa#show map
  # ====================

  def completed_samples
    @completed_samples ||= begin
      samples = base_samples.results_completed
                            .joins(published_research_project_sql)
                            .where(completed_query_string)

      samples = samples_for_primers(samples) if params[:primer]
      samples
    end
  end

  def completed_query_string
    query = {}
    query[:substrate_cd] = params[:substrate].split('|') if params[:substrate]
    query
  end

  # ====================
  # research_project_samples: ResearchProject#show map
  # ====================

  def research_project_samples
    @research_project_samples ||= begin
      return [] if research_project.blank?

      completed_samples
        .where('asvs.research_project_id = ?', research_project.id)
    end
  end

  def research_project
    @research_project ||= begin
      slug = params[:id] || params[:slug]
      ResearchProject.find_by(slug: slug)
    end
  end

  # ====================
  # hero counts
  # ====================

  def base_samples_count_join_sql
    <<~SQL.chomp
      LEFT JOIN research_project_sources
        ON research_project_sources.sourceable_id = samples.id
        AND research_project_sources.sourceable_type = 'Sample'
    SQL
  end

  def optional_published_research_project_count_sql
    "LEFT #{published_research_project_count_sql}"
  end

  def published_research_project_count_sql
    <<~SQL.chomp
      JOIN research_projects
        ON research_projects.id = research_project_sources.research_project_id
        AND research_projects.published = TRUE
    SQL
  end

  def base_samples_count
    website_sample
      .select('samples.id')
      .joins(base_samples_count_join_sql)
  end

  public def approved_samples_count
    @approved_samples_count ||= begin
      base_samples_count.joins(optional_published_research_project_count_sql)
                        .where(conditional_status_sql)
                        .count
    end
  end

  public def completed_samples_count
    @completed_samples_count ||= begin
      base_samples_count.results_completed
                        .joins(published_research_project_count_sql)
                        .count
    end
  end
end
