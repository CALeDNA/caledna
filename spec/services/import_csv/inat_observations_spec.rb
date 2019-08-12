# frozen_string_literal: true

require 'rails_helper'

describe ImportCsv::InatObservations do
  let(:dummy_class) { Class.new { extend ImportCsv::InatObservations } }

  let(:csv) { './spec/fixtures/import_csv/inat_observations.csv' }
  let(:file) { fixture_file_upload(csv, 'text/csv') }
  let(:data) { CSV.read(file.path, headers: true, col_sep: ',') }

  # rubocop:disable Style/DoubleNegation
  def is_i?(string)
    !!(string =~ /\A[-+]?[0-9]+\z/)
  end
  # rubocop:enable Style/DoubleNegation

  describe '#find_canonical_name' do
    def subject(row)
      dummy_class.find_canonical_name(row)
    end

    it 'returns canonical name for species' do
      expect(subject(data[1])).to eq('species2')
    end

    it 'returns canonical name for higher ranks' do
      expect(subject(data[0])).to eq('genus1')
      expect(subject(data[2])).to eq('phylum3')
    end
  end

  describe '#find_taxon_rank' do
    def subject(row)
      dummy_class.find_taxon_rank(row)
    end

    it 'returns taxon rank for species' do
      expect(subject(data[1])).to eq('species')
    end

    it 'returns taxon rank for higher ranks' do
      expect(subject(data[0])).to eq('genus')
      expect(subject(data[2])).to eq('phylum')
    end
  end

  describe '#create_inat_observation' do
    def subject(row)
      dummy_class.create_inat_observation(row)
    end

    it 'creates InatObservation if it does not exist' do
      row = data[0]
      create(:inat_taxon, taxon_id: row['taxon_id'])

      expect { subject(row) }
        .to change(InatObservation, :count).by(1)
    end

    it 'creates InatObservation with correct attributes' do
      row = data[1]
      obs = subject(row)

      expect(obs.observation_id).to eq(row['id'].to_i)
      expect(obs.latitude.to_f).to eq(row['latitude'].to_f)
      expect(obs.longitude.to_f).to eq(row['longitude'].to_f)

      row.each do |key, value|
        next if %w[id latitude longitude created_at updated_at].include?(key)
        next unless obs.try(key)

        expected = is_i?(value) ? value.to_i : value
        expect(obs.send(key)).to eq(expected)
      end
      # expect(obs.attributes).to eq(1)
    end

    it 'does not create InatObservation if it already exists' do
      row = data[0]
      taxon = create(:inat_taxon, taxon_id: row['taxon_id'])
      create(:inat_observation, taxon_id: taxon.id, observation_id: row['id'])

      expect { subject(row) }
        .to change(InatObservation, :count).by(0)
    end
  end

  describe '#create_inat_taxon' do
    def subject(row)
      dummy_class.create_inat_taxon(row)
    end

    it 'creates InatTaxon if it does not exist' do
      row = data[0]

      expect { subject(row) }
        .to change(InatTaxon, :count).by(1)
    end

    it 'creates InatTaxon with correct attributes' do
      row = data[0]
      obs = subject(row)

      expect(obs.taxon_id).to eq(row['taxon_id'].to_i)
      expect(obs.kingdom).to eq(row['taxon_kingdom_name'])
      expect(obs.phylum).to eq(row['taxon_phylum_name'])
      expect(obs.class_name).to eq(row['taxon_class_name'])
      expect(obs.order).to eq(row['taxon_order_name'])
      expect(obs.family).to eq(row['taxon_family_name'])
      expect(obs.genus).to eq(row['taxon_genus_name'])
      expect(obs.species).to eq(row['taxon_species_name'])
      expect(obs.rank).to eq('genus')
      expect(obs.canonical_name).to eq('genus1')
      expect(obs.scientific_name).to eq(row['scientific_name'])
      expect(obs.common_name).to eq(row['common_name'])
      expect(obs.iconic_taxon_name).to eq(row['iconic_taxon_name'])
    end

    it 'does not create InatObservation if it already exists' do
      row = data[0]
      taxon = create(:inat_taxon, taxon_id: row['taxon_id'])
      create(:inat_observation, taxon_id: taxon.id, observation_id: row['id'])

      expect { subject(row) }
        .to change(InatObservation, :count).by(0)
    end
  end

  describe '#import_observations_csv' do
    let(:location) { 'location' }
    let(:project_name) { 'Project' }

    def subject(path, project_name, location)
      dummy_class.import_observations_csv(path, project_name, location)
    end

    it 'creates InatObservation' do
      create(:research_project, name: project_name)
      create(:inat_taxon, taxon_id: data[0]['taxon_id'])
      create(:inat_taxon, taxon_id: data[1]['taxon_id'])
      create(:inat_taxon, taxon_id: data[2]['taxon_id'])

      expect { subject(csv, project_name, location) }
        .to change(InatObservation, :count).by(3)
    end

    it 'creates ResearchProjectSource' do
      create(:research_project, name: project_name)
      create(:inat_taxon, taxon_id: data[0]['taxon_id'])
      create(:inat_taxon, taxon_id: data[1]['taxon_id'])
      create(:inat_taxon, taxon_id: data[2]['taxon_id'])

      expect { subject(csv, project_name, location) }
        .to change(InatObservation, :count).by(3)
    end

    it 'raises error if no path is given' do
      expect { subject(nil, project_name, location) }
        .to raise_error(StandardError, 'must pass in path')
    end

    it 'raises error if no location is given' do
      expect { subject(csv, project_name, nil) }
        .to raise_error(StandardError, 'must pass in location')
    end

    it 'raises error if research project does not exist' do
      message = 'can not find research project for Project'
      expect { subject(csv, project_name, location) }
        .to raise_error(StandardError, message)
    end
  end

  describe '#import_taxa_csv' do
    def subject(path)
      dummy_class.import_taxa_csv(path)
    end

    it 'creates InatTaxon' do
      create(:research_project, name: 'Los Angeles River')
      expect { subject(csv) }
        .to change(InatTaxon, :count).by(3)
    end

    it 'raises error if no path is given' do
      expect { subject(nil) }
        .to raise_error(StandardError, 'must pass in path')
    end
  end
end
