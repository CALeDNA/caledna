# frozen_string_literal: true

require 'rails_helper'

describe ImportCsv::DnaResults do
  let(:dummy_class) { Class.new { extend ImportCsv::DnaResults } }

  describe '#convert_header_to_barcode' do
    def subject(header)
      dummy_class.convert_header_to_barcode(header)
    end

    it 'converts header into valid kit number' do
      header = 'X16S_K0078.C2.S59.L001'

      expect(subject(header)).to eq('K0078-LC-S2')
    end

    it 'converts header into valid kit number' do
      header = 'PITS_K0001A1.S1.L001'

      expect(subject(header)).to eq('K0001-LA-S1')
    end

    it 'converts header into a random sample number' do
      header = 'X16S_ShrubBlank1.S72.L001'

      expect(subject(header)).to eq('ShrubBlank1')
    end
  end

  describe('#import_csv') do
    include ActiveJob::TestHelper

    before(:each) do
      project = create(:field_data_project, name: 'unknown')
      stub_const('FieldDataProject::DEFAULT_PROJECT', project)
    end

    def subject(file, research_project_id, extraction_type_id)
      dummy_class.import_csv(file, research_project_id, extraction_type_id)
    end

    let(:csv) { './spec/fixtures/import_csv/dna_results_tabs.csv' }
    let(:file) { fixture_file_upload(csv, 'text/csv') }
    let(:extraction_type) { create(:extraction_type) }
    let(:research_project) { create(:research_project) }

    context 'when matching sample does not exists' do
      it 'creates sample & extraction' do
        expect { subject(file, research_project.id, extraction_type.id) }
          .to change { Sample.count }
          .by(2)
          .and change { Extraction.count }
          .by(2)
      end
    end

    context 'when matching extraction does not exists' do
      it 'creates extraction' do
        create(:sample, barcode: 'K0001-LA-S1')
        create(:sample, barcode: 'forest')

        expect { subject(file, research_project.id, extraction_type.id) }
          .to change { Sample.count }
          .by(0)
          .and change { Extraction.count }
          .by(2)
      end
    end

    context 'when matching sample exists' do
      it 'does not create sample or extraction' do
        sample = create(:sample, barcode: 'K0001-LA-S1')
        sample2 = create(:sample, barcode: 'forest')
        create(:extraction, sample: sample, extraction_type: extraction_type)
        create(:extraction, sample: sample2, extraction_type: extraction_type)

        expect { subject(file, research_project.id, extraction_type.id) }
          .to change { Sample.count }
          .by(0)
          .and change { Extraction.count }
          .by(0)
      end
    end

    context 'when matching taxon does not exist' do
      before(:each) do
        create(
          :ncbi_node,
          canonical_name: 'Phylum',
          rank: 'phylum',
          lineage: [[3, 'Phylum', 'phylum']]
        )
      end

      it 'does not add ImportCsvCreateAsvJob to queue' do
        expect { subject(file, research_project.id, extraction_type.id) }
          .to_not have_enqueued_job(ImportCsvCreateAsvJob)
      end

      it 'returns invalid' do
        expect(subject(file, research_project.id, extraction_type.id).valid?)
          .to eq(false)
      end
    end

    context 'when matching taxon does exist' do
      before(:each) do
        taxon = create(
          :ncbi_node,
          canonical_name: 'Genus',
          rank: 'genus',
          lineage: [
            [3, 'Phylum', 'phylum'],
            [4, 'Class', 'class'],
            [5, 'Order', 'order'],
            [6, 'Family', 'family'],
            [7, 'Genus', 'genus']
          ]
        )
        create(:ncbi_name, name: 'Genus', taxon_id: taxon.id)

        taxon = create(
          :ncbi_node,
          canonical_name: 'Genus species',
          rank: 'species',
          lineage: [
            [3, 'Phylum', 'phylum'],
            [4, 'Class', 'class'],
            [5, 'Order', 'order'],
            [6, 'Family', 'family'],
            [7, 'Genus', 'genus'],
            [8, 'Genius species', 'species']
          ]
        )
        create(:ncbi_name, name: 'Genus species', taxon_id: taxon.id)
      end

      it 'adds ImportCsvCreateAsvJob to queue' do
        expect { subject(file, research_project.id, extraction_type.id) }
          .to_not have_enqueued_job(ImportCsvCreateAsvJob)
      end

      it 'returns valid' do
        expect(subject(file, research_project.id, extraction_type.id).valid?)
          .to eq(true)
      end
    end
  end
end
