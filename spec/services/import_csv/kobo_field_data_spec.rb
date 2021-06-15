# frozen_string_literal: true

require 'rails_helper'

describe ImportCsv::KoboFieldData do
  before do
    website = create(:website, name: 'foo')
    allow(Website).to receive(:caledna).and_return(website)
    allow(Website).to receive(:la_river).and_return(website)
  end

  let(:dummy_class) { Class.new { extend ImportCsv::KoboFieldData } }
  let(:csv) { './spec/fixtures/import_csv/samples.csv' }
  let(:file) { fixture_file_upload(csv, 'text/csv') }
  let(:field_project_id) { create(:field_project).id }
  let(:rows) do
    delimiter = ';'
    CSV.read(file.path, headers: true, col_sep: delimiter).entries
  end

  describe('#import_csv') do
    include ActiveJob::TestHelper

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

    context 'when CSV has duplicate samples' do
      let(:csv) { './spec/fixtures/import_csv/samples_dup_names.csv' }

      it 'returns an error' do
        result = subject(file, field_project_id)
        message = 'K9999-A2 listed multiple times'

        expect(result.valid?).to eq(false)
        expect(result.errors).to eq(message)
      end
    end

    context 'when samples in the CSV are not in the database' do
      def point_factory(lon, lat)
        RGeo::Cartesian.preferred_factory(srid: 3785).point(lon, lat)
      end

      it 'returns valid' do
        result = subject(file, field_project_id)

        expect(result.valid?).to eq(true)
      end

      it 'enqueues ImportCsvKoboFieldDataJob' do
        expect { subject(file, field_project_id) }
          .to have_enqueued_job(ImportCsvKoboFieldDataJob)
          .exactly(1).times
      end

      it 'passes correct as arguement to ImportCsvKoboFieldDataJob' do
        delimiter = ';'
        data = CSV.read(file.path, headers: true, col_sep: delimiter)

        expect { subject(file, field_project_id) }
          .to have_enqueued_job
          .with(data.to_json, field_project_id).exactly(1).times
      end
    end
  end

  describe '#process_sample' do
    def subject(row, field_project_id)
      dummy_class.process_sample(row, field_project_id)
    end

    let(:row) do
      data = CSV.parse(<<~ROWS, headers: true)
        collection_date,collection_time,environmental_features,environmental_settings,barcode,substrate,
        2020-01-09,12:00,"a, b, c","d, e, f",K1234B1,Water,
      ROWS

      data.entries.first
    end
    let(:field_project_id) { 10 }

    it 'converts sample names' do
      expected = 'K1234-LB-S1'

      expect(subject(row, field_project_id)[:barcode]).to eq(expected)
    end

    it 'accepts dates in YYYY-MM-DD HH:MM format' do
      expected = '2020-01-09 12:00'

      expect(subject(row, field_project_id)[:collection_date]).to eq(expected)
    end

    it 'accepts dates in YYYY/MM/DD HH:MM format' do
      row['collection_date'] = '2020/01/09 12:00'
      expected = '2020-01-09 12:00'

      expect(subject(row, field_project_id)[:collection_date]).to eq(expected)
    end

    it 'accepts dates in MM/DD/YYYY HH:MM format' do
      row['collection_date'] = '01/09/2020 12:00'
      expected = '2020-01-09 12:00'

      expect(subject(row, field_project_id)[:collection_date]).to eq(expected)
    end

    it 'accepts dates in MM-DD-YYYY HH:MM format' do
      row['collection_date'] = '01-09-2020 12:00'
      expected = '2020-01-09 12:00'

      expect(subject(row, field_project_id)[:collection_date]).to eq(expected)
    end

    it 'converts comma separated environmental_features into an array' do
      expected = %w[a b c]

      expect(subject(row, field_project_id)[:environmental_features])
        .to eq(expected)
    end

    it 'converts comma separated environmental_settings into an array' do
      expected = %w[d e f]

      expect(subject(row, field_project_id)[:environmental_settings])
        .to eq(expected)
    end

    it 'converts substrate to lowercase' do
      expected = 'water'

      expect(subject(row, field_project_id)[:substrate_cd]).to eq(expected)
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

      expect(subject(row, field_project_id)[:csv_data]).to eq(expected)
    end
  end

  describe '#kobo_field_data_job' do
    include ActiveJob::TestHelper

    def subject(file, field_project_id)
      delimiter = ';'
      data = CSV.read(file.path, headers: true, col_sep: delimiter)

      dummy_class.kobo_field_data_job(data.to_json, field_project_id)
    end

    it 'enqueues ImportCsvKoboFieldDataJob' do
      expect { subject(file, field_project_id) }
        .to have_enqueued_job(ImportCsvCreateSampleJob)
        .exactly(2).times
    end

    it 'passes correct as arguement to ImportCsvCreateSampleJob' do
      row1 = {
        'barcode' => 'K9999-A1', 'collection_date' => '2019-07-02',
        'collection_time' => '13:30', 'location' => 'Yosemite',
        'latitude' => '34.100001', 'longitude' => '-118.300001',
        'gps_altitude' => '0', 'gps_precision' => '10', 'substrate' => 'soil',
        'habitat' => 'Fully submerged', 'sampling_depth' => 'Submerged >50m',
        'environmental_features' => ' Enclosed water,  Reef ',
        'environmental_settings' => 'Near (<5m) buildings, On farm',
        'light' => nil, 'pH' => nil, 'moisture' => nil,
        'field_notes' => 'my notes', 'country' => 'United States',
        'country_code' => 'US', 'has_permit' => 'true'
      }
      row2 = {
        'barcode' => 'K9999-A2', 'collection_date' => '2019-07-03',
        'collection_time' => '11:30', 'location' => 'Yosemite',
        'latitude' => '34.200001', 'longitude' => '-118.400001',
        'gps_altitude' => '0', 'gps_precision' => '10',
        'substrate' => 'sediment',
        'habitat' => 'Terrestrial habitat, not submerged',
        'sampling_depth' => 'Top layer (top 3cm) soil or sediment',
        'environmental_features' => 'Basin/wash, Rock mound',
        'environmental_settings' => 'On garden, On manmade landscape',
        'light' => nil, 'pH' => nil, 'moisture' => nil,
        'field_notes' => 'my notes 2', 'country' => 'United States',
        'country_code' => 'US', 'has_permit' => 'true'
      }

      expect { subject(file, field_project_id) }
        .to have_enqueued_job
        .with(row1, field_project_id).exactly(1).times
        .with(row2, field_project_id).exactly(1).times
    end

    it 'enqueues HandleApprovedSamplesJob' do
      expect { subject(file, field_project_id) }
        .to have_enqueued_job(HandleApprovedSamplesJob)
        .exactly(1).times
    end
  end
end
