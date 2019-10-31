# frozen_string_literal: true

require 'rails_helper'

describe ImportCsv::EdnaResultsAsvs do
  let(:dummy_class) { Class.new { extend ImportCsv::EdnaResultsMetadata } }

  describe '#import_csv' do
    def subject(file, research_project_id)
      dummy_class.import_csv(file, research_project_id)
    end

    let(:csv) { './spec/fixtures/import_csv/eDNA_results_metadata.csv' }
    let(:file) { fixture_file_upload(csv, 'text/csv') }
    let(:research_project) { create(:research_project) }

    it 'updates a given reseach project' do
      data = CSV.read(file.path, headers: true, col_sep: ',')
      row = data.first

      expect { subject(file, research_project.id) }
        .to change { research_project.reload.reference_barcode_database }
        .to(row['reference_barcode_database'])
        .and change { research_project.dryad_link }
        .to(row['Dryad_link'])
        .and change { research_project.decontamination_method }
        .to(row['decontamination_method'])
        .and change { research_project.primers }
        .to(row['primers'])
    end
  end
end
