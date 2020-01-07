# frozen_string_literal: true

require 'rails_helper'

describe ImportCsv::SamplesCsv do
  let(:dummy_class) { Class.new { extend ImportCsv::SamplesCsv } }

  describe('#import_csv') do
    include ActiveJob::TestHelper

    def subject(file, field_project_id)
      dummy_class.import_csv(file, field_project_id)
    end

    let(:csv) { './spec/fixtures/import_csv/samples.csv' }
    let(:file) { fixture_file_upload(csv, 'text/csv') }
    let(:field_project) { create(:field_project, name: 'foo') }
    let(:barcode1) { 'K9999-A1' }

    context 'when barcodes already exists' do
      let!(:sample) { create(:sample, barcode: barcode1, status: 'approved') }

      it 'does not create samples' do
        expect { subject(file, field_project.id) }
          .to change { Sample.count }.by(0)
      end

      it 'returns error message' do
        results = subject(file, field_project.id)
        expect(results.valid?).to eq(false)
        expect(results.errors).to eq("#{barcode1} already exists")
      end
    end

    context 'when barcodes do not exist' do
      it 'creates samples' do
        expect { subject(file, field_project.id) }
          .to change { Sample.count }.by(2)
      end

      it 'creates samples using csv data' do
        row = CSV.read(file.path, headers: true, col_sep: ';').entries.first
        date =
          DateTime.parse("#{row['collection_date']} #{row['collection_time']}")

        subject(file, field_project.id)
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
          .to eq(['Enclosed water', 'Reef'])
        expect(sample.environmental_settings)
          .to eq(['Near (<5m) buildings', 'On farm'])
        expect(sample.field_notes).to eq(row['field_notes'])
        expect(sample.country).to eq(row['country'])
        expect(sample.country_code).to eq(row['country_code'])
        expect(sample.has_permit).to eq(true)
        expect(sample.field_project_id).to eq(field_project.id)
        expect(sample.status_cd).to eq('approved')
        expect(sample.csv_data).to eq(row.to_h)
      end

      it 'returns valid' do
        results = subject(file, field_project.id)
        expect(results.valid?).to eq(true)
      end
    end
  end
end
