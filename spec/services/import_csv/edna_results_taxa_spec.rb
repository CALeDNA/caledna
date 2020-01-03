# frozen_string_literal: true

require 'rails_helper'

describe ImportCsv::EdnaResultsTaxa do
  let(:dummy_class) { Class.new { extend ImportCsv::EdnaResultsTaxa } }

  describe('#import_csv') do
    include ActiveJob::TestHelper

    before(:each) do
      project = create(:field_project, name: 'unknown')
      stub_const('FieldProject::DEFAULT_PROJECT', project)
    end

    def subject(file, research_project_id, primer, notes)
      dummy_class.import_csv(file, research_project_id, primer, notes)
    end

    let(:csv) { './spec/fixtures/import_csv/dna_results_tabs.csv' }
    let(:file) { fixture_file_upload(csv, 'text/csv') }
    let(:research_project) { create(:research_project) }
    let(:primer) { '12S' }
    let(:notes) { 'notes' }

    it 'adds ImportCsvQueueAsvJob to queue' do
      expect do
        subject(
          file, research_project.id, primer, notes
        )
      end
        .to have_enqueued_job(ImportCsvFindCalTaxonJob).exactly(3).times
    end

    it 'adds ImportCsvCreateRawTaxonomyImportJob to queue' do
      expect do
        subject(
          file, research_project.id, primer, notes
        )
      end
        .to have_enqueued_job(ImportCsvCreateRawTaxonomyImportJob)
        .exactly(2).times
    end

    it 'passes taxonomy string as arguement' do
      expect do
        subject(
          file, research_project.id, primer, notes
        )
      end
        .to have_enqueued_job
        .with('Phylum;Class;Order;Family;Genus;').exactly(1).times
        .with('Phylum;Class;Order;Family;Genus;Genus species').exactly(1).times
    end

    it 'returns valid' do
      expect(
        subject(file, research_project.id, primer, notes).valid?
      )
        .to eq(true)
    end
  end

  describe('#find_cal_taxon') do
    include ActiveJob::TestHelper

    def subject(taxonomy_string)
      dummy_class.find_cal_taxon(taxonomy_string)
    end

    context 'when taxonomy string is phylum format' do
      let(:taxonomy_string) { 'P;C;O;F;G;S' }

      it 'adds ImportCsvCreateCalTaxonJob to queue' do
        expect do
          subject(taxonomy_string)
        end
          .to have_enqueued_job(ImportCsvCreateCalTaxonJob).exactly(1).times
      end

      it 'passes correct arguements to job' do
        arguements = {
          taxonRank: 'species',
          original_hierarchy: {
            species: 'S', genus: 'G', family: 'F', order: 'O',
            class: 'C', phylum: 'P', kingdom: nil, superkingdom: nil
          },
          original_taxonomy_phylum: 'P;C;O;F;G;S',
          original_taxonomy_superkingdom: nil,
          complete_taxonomy: ';;P;C;O;F;G;S',
          normalized: false,
          exact_gbif_match: false
        }

        expect do
          subject(taxonomy_string)
        end
          .to have_enqueued_job.with(arguements).exactly(1).times
      end
    end

    context 'when taxonomy string is superkingdom format' do
      let(:taxonomy_string) { 'SK;P;C;O;F;G;S' }

      it 'adds ImportCsvCreateCalTaxonJob to queue' do
        expect do
          subject(taxonomy_string)
        end
          .to have_enqueued_job(ImportCsvCreateCalTaxonJob).exactly(1).times
      end

      it 'passes correct arguements to job' do
        arguements = {
          taxonRank: 'species',
          original_hierarchy: {
            species: 'S', genus: 'G', family: 'F', order: 'O',
            class: 'C', phylum: 'P', superkingdom: 'SK'
          },
          original_taxonomy_phylum: 'P;C;O;F;G;S',
          original_taxonomy_superkingdom: 'SK;P;C;O;F;G;S',
          complete_taxonomy: 'SK;P;C;O;F;G;S',
          normalized: false,
          exact_gbif_match: false
        }

        expect do
          subject(taxonomy_string)
        end
          .to have_enqueued_job.with(arguements).exactly(1).times
      end
    end
  end
end
