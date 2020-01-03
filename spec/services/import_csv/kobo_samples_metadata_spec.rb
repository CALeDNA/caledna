# frozen_string_literal: true

require 'rails_helper'

describe ImportCsv::KoboSamplesMetadata do
  let(:dummy_class) { Class.new { extend ImportCsv::KoboSamplesMetadata } }

  describe('#import_csv') do
    include ActiveJob::TestHelper

    def subject(file)
      dummy_class.import_csv(file)
    end
    let(:csv) { './spec/fixtures/import_csv/samples_metadata.csv' }
    let(:file) { fixture_file_upload(csv, 'text/csv') }
    let(:rows) do
      delimiter = ','
      raw_rows = []
      CSV.foreach(file.path, headers: true, col_sep: delimiter) do |row|
        raw_rows << row
      end
      raw_rows
    end

    context 'when samples in the CSV are not in the database' do
      it 'returns error message for missing samples' do
        create(:sample, barcode: rows.first['barcode'], status: 'approved')

        message = "#{rows.second['barcode']} are not in the database"
        expected = OpenStruct.new(valid?: false, errors: message)

        expect(subject(file)).to eq(expected)
      end

      it 'does not update metadata for existing samples' do
        sample =
          create(:sample, barcode: rows.first['barcode'], status: 'approved')

        expect { subject(file) }.to_not(change { sample.metadata })
      end
    end

    context 'when samples in the CSV are in the database' do
      context 'and samples are approved' do
        it 'returns valid is true' do
          create(:sample, barcode: rows.first['barcode'],
                          status: 'approved')
          create(:sample, barcode: rows.second['barcode'],
                          status: 'results_completed')

          expected = OpenStruct.new(valid?: true, errors: nil)

          expect(subject(file)).to eq(expected)
        end

        it 'updates metadata for existing samples' do
          sample1 = create(:sample, barcode: rows.first['barcode'],
                                    status: 'approved')
          sample2 = create(:sample, barcode: rows.second['barcode'],
                                    status: 'results_completed')
          row1 = rows.first
          row2 = rows.second

          expect { subject(file) }
            .to change { sample1.reload.metadata }
            .from({}).to('field1' => row1['field1'], 'field2' => row1['field2'])
            .and change { sample2.reload.metadata }
            .from({}).to('field1' => row2['field1'], 'field2' => row2['field2'])
        end
      end

      context 'and samples are not approved' do
        it 'returns error message' do
          create(:sample, barcode: rows.first['barcode'],
                          status: 'submitted')
          create(:sample, barcode: rows.second['barcode'],
                          status: 'submitted')

          message = "#{rows.first['barcode']}, #{rows.second['barcode']}" \
            ' are not in the database'
          expected = OpenStruct.new(valid?: false, errors: message)

          expect(subject(file)).to eq(expected)
        end

        it 'does not update metadata for existing samples' do
          sample1 = create(:sample, barcode: rows.first['barcode'],
                                    status: 'submitted')
          sample2 = create(:sample, barcode: rows.second['barcode'],
                                    status: 'submitted')
          subject(file)

          expect(sample1.metadata).to eq({})
          expect(sample2.metadata).to eq({})
        end
      end
    end
  end
end
