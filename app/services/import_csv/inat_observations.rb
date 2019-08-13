# frozen_string_literal: true

module ImportCsv
  module InatObservations
    def import_observations_csv(path, project_name, location)
      check_task_args(path, :path)
      check_task_args(location, :location)

      project = fetch_research_project(project_name)

      CSV.foreach(path, headers: true, col_sep: ',') do |row|
        create_inat_observation(row)
        create_research_project_source(row, project, location)
      end
    end

    def import_taxa_csv(path)
      check_task_args(path, :path)

      CSV.foreach(path, headers: true, col_sep: ',') do |row|
        create_inat_taxon(row)
      end
    end

    # rubocop:disable Metrics/MethodLength
    def find_taxon_rank(row)
      attributes = [
        { field: 'taxon_species_name', rank: 'species' },
        { field: 'taxon_genus_name', rank: 'genus' },
        { field: 'taxon_family_name', rank: 'family' },
        { field: 'taxon_order_name', rank: 'order' },
        { field: 'taxon_class_name', rank: 'class' },
        { field: 'taxon_phylum_name', rank: 'phylum' },
        { field: 'taxon_kingdom_name', rank: 'kingdom' }
      ]

      attributes.each do |attribute|
        break attribute[:rank] if row[attribute[:field]].present?
      end
    end
    # rubocop:enable Metrics/MethodLength

    def find_canonical_name(row)
      names = %w[taxon_species_name taxon_genus_name taxon_family_name
                 taxon_order_name taxon_class_name taxon_phylum_name
                 taxon_kingdom_name]

      names.each do |name|
        break row[name] if row[name].present?
      end
    end

    def create_research_project_source(row, project, location)
      attributes = {
        research_project_id: project.id,
        sourceable_id: row['id'],
        sourceable_type: 'InatObservation',
        metadata: { location: location }
      }
      ResearchProjectSource.where(attributes).first_or_create
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def create_inat_observation(row)
      record = InatObservation.find_by(observation_id: row['id'])
      return if record.present?
      puts row['id']

      attributes = {
        observation_id: row['id'],
        time_observed_at: row['time_observed_at'],
        user_id: row['user_id'],
        user_login: row['user_login'],
        quality_grade: row['quality_grade'],
        license: row['license'],
        url: row['url'],
        image_url: row['image_url'],
        tag_list: row['tag_list'],
        description: row['description'],
        num_identification_agreements: row['num_identification_agreements'],
        num_identification_disagreements:
          row['num_identification_disagreements'],
        place_guess: row['place_guess'],
        latitude: row['latitude'],
        longitude: row['longitude'],
        positional_accuracy: row['positional_accuracy'],
        coordinates_obscured: row['coordinates_obscured'],
        taxon_id: row['taxon_id'],
        canonical_name: find_canonical_name(row)
      }

      obs = InatObservation.create(attributes)
      puts obs.errors.messages unless obs.valid?
      obs
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def create_inat_taxon(row)
      record = InatTaxon.find_by(taxon_id: row['taxon_id'])
      return if record.present?

      attributes = {
        taxon_id: row['taxon_id'],
        scientific_name: row['scientific_name'],
        common_name: row['common_name'],
        iconic_taxon_name: row['iconic_taxon_name'],
        kingdom: row['taxon_kingdom_name'],
        phylum: row['taxon_phylum_name'],
        class_name: row['taxon_class_name'],
        order: row['taxon_order_name'],
        family: row['taxon_family_name'],
        genus: row['taxon_genus_name'],
        species: row['taxon_species_name'],
        rank: find_taxon_rank(row),
        canonical_name: find_canonical_name(row)
      }

      InatTaxon.create(attributes)
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    private

    def check_task_args(arg, type)
      raise StandardError, "must pass in #{type}" if arg.blank?
    end

    def fetch_research_project(name)
      project = ResearchProject.find_by(name: name)
      if project.blank?
        raise StandardError, "can not find research project for #{name}"
      end

      project
    end
  end
end
