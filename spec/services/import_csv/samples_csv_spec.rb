# frozen_string_literal: true

require 'rails_helper'

describe ImportCsv::SamplesCsv do
  let(:dummy_class) { Class.new { extend ImportCsv::SamplesCsv } }

  describe('#import_csv') do
    include ActiveJob::TestHelper

    def subject(file, research_project_id)
      dummy_class.import_csv(file, research_project_id)
    end

    let(:csv) { './spec/fixtures/import_csv/samples.csv' }
    let(:file) { fixture_file_upload(csv, 'text/csv') }
    let(:research_project) { create(:research_project) }
    let!(:field_project) { create(:field_project, name: 'unknown') }

    context 'sample exists' do
      let!(:sample) { create(:sample, barcode: 'K9999-A1') }

      it 'does not create sample' do
        expect { subject(file, research_project.id) }
          .to change { Sample.count }.by(0)
      end

      it 'does not create extraction' do
        expect { subject(file, research_project.id) }
          .to change { Extraction.count }.by(0)
      end

      it 'does not create research project source' do
        expect { subject(file, research_project.id) }
          .to change { ResearchProjectSource.count }.by(0)
      end
    end

    context 'sample does not exists' do
      it 'creates a sample' do
        expect { subject(file, research_project.id) }
          .to change { Sample.count }.by(1)
      end

      it 'creates a sample using csv data' do
        row = CSV.read(file.path, headers: true, col_sep: ';').entries.first
        date =
          DateTime.parse("#{row['collection_date']} #{row['collection_time']}")

        subject(file, research_project.id)
        sample = Sample.first

        expect(sample.barcode).to eq(row['barcode'])
        expect(sample.collection_date).to eq(date)
        expect(sample.submission_date).to eq(date)
        expect(sample.location).to eq(row['location'])
        expect(sample.latitude).to eq(row['latitude'].to_f)
        expect(sample.longitude).to eq(row['longitude'].to_f)
        expect(sample.altitude).to eq(row['gps_altitude'].to_i)
        expect(sample.gps_precision).to eq(row['gps_precision'].to_i)
        expect(sample.substrate_cd).to eq(row['substrate'])
        expect(sample.habitat_cd).to eq(row['habitat'])
        expect(sample.depth_cd).to eq(row['sampling_depth'])
        expect(sample.environmental_features)
          .to eq(row['environmental_features'].split(','))
        expect(sample.environmental_settings)
          .to eq(row['environmental_settings'].split(','))
        expect(sample.field_notes).to eq(row['field_notes'])
        expect(sample.country).to eq(row['country'])
        expect(sample.country_code).to eq(row['country_code'])
        expect(sample.has_permit).to eq(true)
        expect(sample.field_project_id).to eq(field_project.id)
        expect(sample.status_cd).to eq('approved')
        expect(sample.csv_data).to eq(row.to_a)
      end

      it 'creates a extraction' do
        expect { subject(file, research_project.id) }
          .to change { Extraction.count }.by(1)
      end

      it 'create a research project source' do
        expect { subject(file, research_project.id) }
          .to change { ResearchProjectSource.count }.by(1)
      end
    end
  end
end
