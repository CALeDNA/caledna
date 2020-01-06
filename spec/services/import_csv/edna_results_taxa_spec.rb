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

    def subject(file, research_project_id, primer)
      dummy_class.import_csv(file, research_project_id, primer)
    end

    let(:csv) { './spec/fixtures/import_csv/dna_results_tabs.csv' }
    let(:file) { fixture_file_upload(csv, 'text/csv') }
    let(:research_project) { create(:research_project) }
    let(:primer) { '12S' }
    let(:notes) { 'notes' }

    it 'adds ImportCsvQueueAsvJob to queue' do
      expect do
        subject(
          file, research_project.id, primer
        )
      end
        .to have_enqueued_job(ImportCsvFindCalTaxonJob).exactly(3).times
    end

    it 'adds ImportCsvCreateRawTaxonomyImportJob to queue' do
      expect do
        subject(
          file, research_project.id, primer
        )
      end
        .to have_enqueued_job(ImportCsvCreateRawTaxonomyImportJob)
        .exactly(2).times
    end

    it 'passes correct as arguement' do
      source = "#{research_project.id}|#{primer}"
      expect do
        subject(
          file, research_project.id, primer
        )
      end
        .to have_enqueued_job
        .with('Phylum;Class;Order;Family;Genus;', source).exactly(1).times
        .with('Phylum;Class;Order;Family;Genus;Genus species', source)
        .exactly(1).times
    end

    it 'returns valid' do
      expect(
        subject(file, research_project.id, primer).valid?
      )
        .to eq(true)
    end
  end

  describe('#find_cal_taxon') do
    include ActiveJob::TestHelper

    def subject(taxonomy_string, attributes)
      dummy_class.find_cal_taxon(taxonomy_string, attributes)
    end
    let(:source_data) { '1|12S' }

    context 'when taxonomy string is phylum format' do
      let(:taxonomy_string) { 'P;C;O;F;G;S' }

      context 'when CalTaxon matches taxonomy string' do
        it 'adds does not ImportCsvCreateCalTaxonJob to queue' do
          create(:cal_taxon, clean_taxonomy_string: taxonomy_string,
                             original_taxonomy_string: taxonomy_string)

          expect do
            subject(taxonomy_string, source_data)
          end
            .to_not have_enqueued_job(ImportCsvCreateCalTaxonJob)
        end
      end

      context 'when CalTaxon does not matches taxonomy string' do
        it 'adds ImportCsvCreateCalTaxonJob to queue' do
          expect do
            subject(taxonomy_string, source_data)
          end
            .to have_enqueued_job(ImportCsvCreateCalTaxonJob).exactly(1).times
        end

        it 'passes correct arguements to job' do
          arguements = {
            taxon_id: nil,
            taxon_rank: 'species',
            hierarchy: {
              species: 'S', genus: 'G', family: 'F', order: 'O',
              class: 'C', phylum: 'P'
            },
            original_taxonomy_string: taxonomy_string,
            clean_taxonomy_string: taxonomy_string,
            normalized: false,
            sources: [source_data]
          }

          expect do
            subject(taxonomy_string, source_data)
          end
            .to have_enqueued_job.with(arguements).exactly(1).times
        end
      end
    end

    context 'when taxonomy string is superkingdom format' do
      let(:taxonomy_string) { 'SK;P;C;O;F;G;S' }

      context 'when CalTaxon matches taxonomy string' do
        it 'adds does not ImportCsvCreateCalTaxonJob to queue' do
          create(:cal_taxon, clean_taxonomy_string: taxonomy_string,
                             original_taxonomy_string: taxonomy_string)

          expect do
            subject(taxonomy_string, source_data)
          end
            .to_not have_enqueued_job(ImportCsvCreateCalTaxonJob)
        end
      end

      context 'when CalTaxon does not match taxonomy string' do
        it 'adds ImportCsvCreateCalTaxonJob to queue' do
          expect do
            subject(taxonomy_string, source_data)
          end
            .to have_enqueued_job(ImportCsvCreateCalTaxonJob).exactly(1).times
        end

        it 'passes correct arguements to job' do
          arguements = {
            taxon_id: nil,
            taxon_rank: 'species',
            hierarchy: {
              species: 'S', genus: 'G', family: 'F', order: 'O',
              class: 'C', phylum: 'P', superkingdom: 'SK'
            },
            original_taxonomy_string: taxonomy_string,
            clean_taxonomy_string: taxonomy_string,
            normalized: false,
            sources: [source_data]
          }

          expect do
            subject(taxonomy_string, source_data)
          end
            .to have_enqueued_job.with(arguements).exactly(1).times
        end
      end
    end

    context 'when CalTaxon exists' do
      let(:taxonomy_string) { 'P;C;O;F;G;S' }

      it 'appends source data' do
        old_source = '99|16S'
        taxon = create(:cal_taxon, original_taxonomy_string: taxonomy_string,
                                   sources: [old_source])

        expect do
          subject(taxonomy_string, source_data)
        end
          .to change { taxon.reload.sources }
          .from([old_source])
          .to([old_source, source_data])
      end
    end
  end
end
