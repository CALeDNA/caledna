# frozen_string_literal: true

module GlobiService
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def add_ncbi_gbif_ids(globi, ids, type)
    return if ids.blank?
    return if globi.blank?

    fields =  {
      target: { ncbi: :target_ncbi_id, gbif: :target_gbif_id },
      source: { ncbi: :source_ncbi_id, gbif: :source_gbif_id }
    }

    ids.split('|').each do |id|
      if id.include?('NCBI')
        _source, id = id.split(':')
        attr = { fields[type][:ncbi] => id }
        globi.update(attr)
      end

      next unless id.include?('GBIF')
      _source, id = id.split(':')

      attr = { fields[type][:gbif] => id }
      globi.update(attr)
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def display_globi_for(ncbi_id)
    active = []
    passive = []
    neutral = []

    interactions = fetch_globi(ncbi_id)

    interactions.each do |globi|
      interaction = if source?(globi, ncbi_id)
                      format_iteraction(globi, 'source')
                    else
                      format_iteraction(globi, 'target')
                    end

      if active_types.include?(interaction[:type])
        active << interaction
      elsif passive_types.include?(interaction[:type])
        passive << interaction
      else
        neutral << interaction
      end
    end

    {
      active: sort_interactions(active),
      passive: sort_interactions(passive),
      neutral: sort_interactions(neutral)
    }
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def format_iteraction(interaction, relationship)
    type = interaction.interaction_type

    if relationship == 'source'
      {
        type: format_type(type),
        taxon_name: interaction.target_ncbi_name ||
          interaction.target_globi_name,
        taxon_id: interaction.target_cal_id,
        asvs_count: interaction.target_asvs_count
      }
    elsif relationship == 'target'
      type = InteractionType::TYPES[type.to_sym]
      {
        type: format_type(type),
        taxon_name: interaction.source_ncbi_name ||
          interaction.source_globi_name,
        taxon_id: interaction.source_cal_id,
        asvs_count: interaction.source_asvs_count
      }
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  private

  def sort_interactions(interactions)
    return [] if interactions.blank?

    interactions.sort_by do |globi|
      [globi[:type], globi[:taxon_name]]
    end
  end

  def conn
    @conn ||= ActiveRecord::Base.connection
  end

  def format_type(type)
    type.underscore.humanize.downcase
  end

  def active_types
    InteractionType::ACTIVE_TYPES.map { |t| format_type(t) }
  end

  def passive_types
    InteractionType::PASSIVE_TYPES.map { |t| format_type(t) }
  end

  def neutral?(globi)
    globi.interactionTypeName == 'interactsWith'
  end

  def source?(globi, ncbi_id)
    globi.source_ncbi_id == ncbi_id
  end

  def fetch_globi_sql
    # NOTE: NcbiNode.ncbi_id is the id from NCBI taxonomy database
    # NcbiNode.taxon_id is id from CALeDNA that use NCBI and BOLD;
    # use ncbi_id to match NcbiNode to GlobiInteraction; use taxon_id
    # to form links for taxa on the site.
    <<-SQL
      SELECT globi."interactionTypeName" AS interaction_type,
      ncbi_target.taxon_id AS target_cal_id,
      ncbi_target.asvs_count AS target_asvs_count,
      ncbi_target.canonical_name AS target_ncbi_name,
      globi.target_ncbi_id AS target_ncbi_id,
      globi."targetTaxonName" AS target_globi_name,

      ncbi_source.taxon_id AS source_cal_id,
      ncbi_source.asvs_count AS source_asvs_count,
      ncbi_source.canonical_name AS source_ncbi_name,
      globi.source_ncbi_id AS source_ncbi_id,
      globi."sourceTaxonName" AS source_globi_name

      FROM external.globi_interactions AS globi
      LEFT JOIN ncbi_nodes AS ncbi_target
        ON globi.target_ncbi_id = ncbi_target.ncbi_id
      LEFT JOIN ncbi_nodes AS ncbi_source
        on globi.source_ncbi_id = ncbi_source.ncbi_id
      where globi.target_ncbi_id = $1 or globi.source_ncbi_id = $1
      group by globi."interactionTypeName",
      globi."targetTaxonName",
      globi."sourceTaxonName",
      ncbi_target.taxon_id,
      ncbi_source.taxon_id,
      globi.target_ncbi_id,
      globi.source_ncbi_id;
    SQL
  end

  def fetch_globi(ncbi_id)
    raw_records = conn.exec_query(fetch_globi_sql, 'q', [[nil, ncbi_id]])
    raw_records.map { |r| OpenStruct.new(r) }
  end
end
