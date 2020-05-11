# frozen_string_literal: true

require 'rails_helper'

describe ImportCsv::KoboFieldData do
  let(:dummy_class) { Class.new { extend ImportCsv::KoboFieldData } }
  let(:csv) { './spec/fixtures/import_csv/samples.csv' }
  let(:file) { fixture_file_upload(csv, 'text/csv') }
  let(:field_project_id) { create(:field_project).id }
  let(:rows) do
    delimiter = ';'
    CSV.read(file.path, headers: true, col_sep: delimiter).entries
  end

  describe('#import_csv') do
    def subject(file, field_project_id)
      dummy_class.import_csv(file, field_project_id)
    end

    context 'when samples in CSV are already in in database' do
      let(:existing_barcode) { rows.first['barcode'] }
      before(:each) do
        create(:sample, barcode: existing_barcode)
      end

      it 'returns an error' do
        result = subject(file, field_project_id)
        message = "#{existing_barcode} already in the database"

        expect(result.valid?).to eq(false)
        expect(result.errors).to eq(message)
      end
    end

    context 'when samples in the CSV are not in the database' do
      it 'returns valid' do
        result = subject(file, field_project_id)

        expect(result.valid?).to eq(true)
      end

      it 'creates samples for each row' do
        expect { subject(file, field_project_id) }
          .to change(Sample, :count).by(2)
      end

      it 'uses csv data to create samples' do
        subject(file, field_project_id)
        sample = Sample.first
        row = rows.first
        collection_date =
          DateTime.parse("#{row['collection_date']} #{row['collection_time']}")
        features = row['environmental_features'].split(',').map(&:strip)
        settings = row['environmental_settings'].split(',').map(&:strip)

        expect(sample.barcode).to eq(row['barcode'])
        expect(sample.collection_date).to eq(collection_date)
        expect(sample.location).to eq(row['location'])
        expect(sample.latitude).to eq(row['latitude'].to_f)
        expect(sample.longitude).to eq(row['longitude'].to_f)
        expect(sample.altitude).to eq(row['gps_altitude'].to_i)
        expect(sample.gps_precision).to eq(row['gps_precision'].to_i)
        expect(sample.substrate_cd).to eq(row['substrate'])
        expect(sample.habitat_cd).to eq(row['habitat'])
        expect(sample.depth_cd).to eq(row['sampling_depth'])
        expect(sample.environmental_features).to eq(features)
        expect(sample.environmental_settings).to eq(settings)
        expect(sample.field_notes).to eq(row['field_notes'])
        expect(sample.country).to eq(row['country'])
        expect(sample.country_code).to eq(row['country_code'])
        expect(sample.has_permit.to_s).to eq(row['has_permit'])
        expect(sample.field_project_id).to eq(field_project_id)
        expect(sample.status_cd).to eq('approved')
        expect(sample.csv_data).to eq(row.to_h.reject { |k, _v| k.blank? })
      end
    end
  end

  describe '#process_sample' do
    def subject(hash, field_project_id)
      dummy_class.process_sample(hash, field_project_id)
    end

    let(:hash) do
      {
        'collection_date' => '2020-01-09',
        'collection_time' => '12:00',
        'environmental_features' => 'a, b, c',
        'environmental_settings' => 'd, e, f',
        'barcode' => 'K1234B1',
        'substrate' => 'Water',
        nil => nil
      }
    end
    let(:field_project_id) { 10 }

    it 'converts sample names' do
      expected = 'K1234-LB-S1'

      expect(subject(hash, field_project_id)[:barcode]).to eq(expected)
    end

    it 'accepts dates in YYYY-MM-DD HH:MM format' do
      expected = '2020-01-09 12:00'

      expect(subject(hash, field_project_id)[:collection_date]).to eq(expected)
    end

    it 'accepts dates in YYYY/MM/DD HH:MM format' do
      hash['collection_date'] = '2020/01/09 12:00'
      expected = '2020-01-09 12:00'

      expect(subject(hash, field_project_id)[:collection_date]).to eq(expected)
    end

    it 'accepts dates in MM/DD/YYYY HH:MM format' do
      hash['collection_date'] = '01/09/2020 12:00'
      expected = '2020-01-09 12:00'

      expect(subject(hash, field_project_id)[:collection_date]).to eq(expected)
    end

    it 'accepts dates in MM-DD-YYYY HH:MM format' do
      hash['collection_date'] = '01-09-2020 12:00'
      expected = '2020-01-09 12:00'

      expect(subject(hash, field_project_id)[:collection_date]).to eq(expected)
    end

    it 'converts comma separated environmental_features into an array' do
      expected = %w[a b c]

      expect(subject(hash, field_project_id)[:environmental_features])
        .to eq(expected)
    end

    it 'converts comma separated environmental_settings into an array' do
      expected = %w[d e f]

      expect(subject(hash, field_project_id)[:environmental_settings])
        .to eq(expected)
    end

    it 'converts substrate to lowercase' do
      expected = 'water'

      expect(subject(hash, field_project_id)[:substrate_cd]).to eq(expected)
    end

    it 'store original hash except nil key value pairs in csv_data' do
      expected = {
        'collection_date' => '2020-01-09',
        'collection_time' => '12:00',
        'environmental_features' => 'a, b, c',
        'environmental_settings' => 'd, e, f',
        'barcode' => 'K1234B1',
        'substrate' => 'Water'
      }

      expect(subject(hash, field_project_id)[:csv_data]).to eq(expected)
    end
  end
end
