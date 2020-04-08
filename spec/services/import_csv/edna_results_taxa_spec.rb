# frozen_string_literal: true

require 'rails_helper'

describe ImportCsv::EdnaResultsTaxa do
  let(:dummy_class) { Class.new { extend ImportCsv::EdnaResultsTaxa } }

  describe('#import_csv') do
    include ActiveJob::TestHelper

    def subject(file, research_project_id, primer)
      dummy_class.import_csv(file, research_project_id, primer)
    end

    let(:file) { fixture_file_upload(csv, 'text/csv') }
    let(:research_project) { create(:research_project) }
    let(:primer) { '12S' }
    let(:notes) { 'notes' }

    context 'csv contain valid taxa strings' do
      let(:csv) { './spec/fixtures/import_csv/dna_results_tabs.csv' }

      it 'returns valid' do
        expect(subject(file, research_project.id, primer).valid?).to eq(true)
      end

      it 'adds ImportCsvQueueAsvJob to queue' do
        expect { subject(file, research_project.id, primer) }
          .to have_enqueued_job(ImportCsvFindResultTaxonJob).exactly(3).times
      end

      it 'passes correct as arguement' do
        source = "#{research_project.id}|#{primer}"
        expect { subject(file, research_project.id, primer) }
          .to have_enqueued_job
          .with('Phylum;Class;Order;Family;Genus;', source).exactly(1).times
          .with('Phylum;Class;Order;Family;Genus;Genus species', source)
          .exactly(1).times
      end
    end

    context 'csv contain invalid taxa strings' do
      let(:csv) { './spec/fixtures/import_csv/dna_results_invalid_tabs.csv' }

      it 'returns invalid' do
        result = subject(file, research_project.id, primer)
        message =
          'Superkingdom;Kingdom;Phylum;Class;Order;Family;; is invalid format'

        expect(result.valid?).to eq(false)
        expect(result.errors).to eq(message)
      end

      it 'does not add ImportCsvQueueAsvJob to queue' do
        expect { subject(file, research_project.id, primer) }
          .to have_enqueued_job(ImportCsvFindResultTaxonJob).exactly(0).times
      end
    end
  end

  describe('#find_result_taxon') do
    include ActiveJob::TestHelper

    shared_examples 'find result taxon' do
      context 'when ResultTaxon matches taxonomy string' do
        it 'adds does not ImportCsvCreateResultTaxonJob to queue' do
          create(:result_taxon, clean_taxonomy_string: taxonomy_string,
                                original_taxonomy_string: taxonomy_string)

          expect { subject(taxonomy_string, source_data) }
            .to_not have_enqueued_job(ImportCsvCreateResultTaxonJob)
        end

        context 'and source data is new' do
          it 'appends source data' do
            old_source = '2|primer2'
            taxon =
              create(:result_taxon, original_taxonomy_string: taxonomy_string,
                                    sources: [old_source])

            expect { subject(taxonomy_string, source_data) }
              .to change { taxon.reload.sources }
              .from([old_source])
              .to([old_source, source_data])
          end
        end

        context 'and source data already exists' do
          it 'does not append source data' do
            taxon =
              create(:result_taxon, original_taxonomy_string: taxonomy_string,
                                    sources: [source_data])

            expect { subject(taxonomy_string, source_data) }
              .to_not(change { taxon.reload.sources })
          end
        end
      end

      context 'when ResultTaxon does not matches taxonomy string' do
        it 'adds ImportCsvCreateResultTaxonJob to queue' do
          expect { subject(taxonomy_string, source_data) }
            .to have_enqueued_job(ImportCsvCreateResultTaxonJob)
            .exactly(1).times
        end
      end
    end

    def subject(taxonomy_string, attributes)
      dummy_class.find_result_taxon(taxonomy_string, attributes)
    end
    let(:source_data) { '1|primer1' }

    context 'when taxonomy string is phylum format' do
      let(:taxonomy_string) { 'P;C;O;F;G;S' }
      include_examples 'find result taxon'

      context 'when ResultTaxon does not matches taxonomy string' do
        context 'and taxon is in the database' do
          it 'passes correct arguements to job' do
            hierarchy_names = { phylum: 'P', class: 'C', order: 'O',
                                family: 'F', genus: 'G', species: 'S' }
            taxon = create(:ncbi_node, hierarchy_names: hierarchy_names,
                                       rank: 'species')

            arguements = {
              taxon_id: taxon.taxon_id,
              taxon_rank: 'species',
              hierarchy: {
                species: 'S', genus: 'G', family: 'F', order: 'O',
                class: 'C', phylum: 'P'
              },
              original_taxonomy_string: taxonomy_string,
              clean_taxonomy_string: taxonomy_string,
              normalized: true,
              exact_match: true,
              sources: [source_data]
            }

            expect { subject(taxonomy_string, source_data) }
              .to have_enqueued_job.with(arguements).exactly(1).times
          end
        end

        context 'and taxon is not in the database' do
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
              exact_match: false,
              sources: [source_data]
            }

            expect { subject(taxonomy_string, source_data) }
              .to have_enqueued_job.with(arguements).exactly(1).times
          end
        end
      end
    end

    context 'when taxonomy string is superkingdom format' do
      let(:taxonomy_string) { 'SK;P;C;O;F;G;S' }
      include_examples 'find result taxon'

      context 'when ResultTaxon does not matches taxonomy string' do
        context 'and taxon is in the database' do
          it 'passes correct arguements to job' do
            hierarchy_names = { phylum: 'P', class: 'C', order: 'O',
                                family: 'F', genus: 'G', species: 'S',
                                superkingdom: 'SK' }
            taxon = create(:ncbi_node, hierarchy_names: hierarchy_names,
                                       rank: 'species')

            arguements = {
              taxon_id: taxon.taxon_id,
              taxon_rank: 'species',
              hierarchy: {
                species: 'S', genus: 'G', family: 'F', order: 'O',
                class: 'C', phylum: 'P', superkingdom: 'SK'
              },
              original_taxonomy_string: taxonomy_string,
              clean_taxonomy_string: taxonomy_string,
              normalized: true,
              exact_match: true,
              sources: [source_data]
            }

            expect { subject(taxonomy_string, source_data) }
              .to have_enqueued_job.with(arguements).exactly(1).times
          end
        end

        context 'and taxon is not in the database' do
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
              exact_match: false,
              sources: [source_data]
            }

            expect { subject(taxonomy_string, source_data) }
              .to have_enqueued_job.with(arguements).exactly(1).times
          end
        end
      end
    end
  end
end
