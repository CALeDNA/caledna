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
    [
      'id', 'latitude', 'longitude', 'barcode', 'status_cd', 'substrate_cd',
      'location', 'collection_date', 'samples.primers as primer_names',
      'primer_ids', 'taxa_count'
    ]
  end
  module_function :sample_columns

  def sample_primers_sql
    <<~SQL.chomp
      LEFT JOIN sample_primers ON sample_primers.sample_id = samples.id
    SQL
  end

  def published_research_project_sql
    <<~SQL.chomp
      JOIN research_projects
        ON sample_primers.research_project_id = research_projects.id
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
      .where('sample_primers.primer_id IN (?)', primer_ids.map(&:to_i))
  end

  def base_samples
    website_sample
      .select(sample_columns)
      .joins(sample_primers_sql)
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

  def taxa_select
    <<~SQL.chomp
      (ARRAY_AGG("ncbi_nodes"."canonical_name" || '|' ||
      ncbi_nodes.taxon_id))[0:10] AS taxa
    SQL
  end

  def taxa_join_sql
    <<~SQL.chomp
      JOIN asvs ON asvs.sample_id = samples.id
      JOIN ncbi_nodes ON ncbi_nodes.taxon_id = asvs.taxon_id
      AND (ncbi_nodes.iucn_status IS NULL OR
        ncbi_nodes.iucn_status NOT IN
        ('#{IucnStatus::THREATENED.values.join("','")}')
      )
    SQL
  end

  def taxa_published_research_project_sql
    <<~SQL.chomp
      JOIN research_projects
        ON asvs.research_project_id = research_projects.id
        AND research_projects.published = TRUE
    SQL
  end

  def taxa_samples
    @taxa_samples ||= begin
      samples = website_sample.results_completed
                              .select(sample_columns)
                              .select(taxa_select)
                              .joins(taxa_join_sql)
                              .joins(taxa_published_research_project_sql)
                              .where(completed_query_string)
                              .order(:created_at)
                              .group(:id)

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
        .where('sample_primers.research_project_id = ?', research_project.id)
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
