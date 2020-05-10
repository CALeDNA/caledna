# frozen_string_literal: true

# used for api/v1/samples, api/v1/field_projects
module FilterSamples
  include CheckWebsite

  private

  # ====================
  # common
  # ====================

  def website_sample
    CheckWebsite.caledna_site? ? Sample : Sample.la_river
  end

  def samples_join_sql
    <<~SQL.chomp
      LEFT JOIN asvs ON asvs.sample_id = samples.id
      LEFT JOIN primers ON primers.id = asvs.primer_id
    SQL
  end

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

  def sample_primers_sql
    <<~SQL.chomp
      JOIN sample_primers ON sample_primers.sample_id = asvs.sample_id
      AND sample_primers.primer_id = asvs.primer_id
      AND sample_primers.research_project_id = asvs.research_project_id
    SQL
  end

  module_function def sample_columns
    %i[
      id latitude longitude barcode status_cd substrate_cd
      location collection_date
    ]
  end

  def samples_for_primers(samples)
    primer_ids = params[:primer].split('|')

    samples
      .joins(sample_primers_sql)
      .where('sample_primers.primer_id IN (?)', primer_ids.map(&:to_i))
  end

  def base_samples
    website_sample
      .joins(samples_join_sql)
      .order(:created_at)
      .select(sample_columns)
      .select(primer_names_sql)
      .select(primer_ids_sql)
      .select('COUNT(DISTINCT asvs.taxon_id) as taxa_count')
      .group(:id)
  end

  # ====================
  # approved_samples: Samples#index map, FieldProject#show map
  # ====================

  def approved_samples
    @approved_samples ||= begin
      samples = base_samples.approved.where(approved_query_string)

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
  # completed_samples: /api/taxa
  # ====================

  def completed_samples
    @completed_samples ||= begin
      samples = base_samples.results_completed.where(completed_query_string)

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
    @research_project ||= ResearchProject.find_by(slug: params[:id])
  end
end
