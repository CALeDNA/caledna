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

      it 'adds ImportCsvFindResultTaxonJob to queue' do
        expect { subject(file, research_project.id, primer) }
          .to have_enqueued_job(ImportCsvUpdateOrCreateResultTaxonJob)
          .exactly(3).times
      end

      it 'passes correct as arguement to ImportCsvFindResultTaxonJob' do
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

      it 'does not add ImportCsvFindResultTaxonJob to queue' do
        expect { subject(file, research_project.id, primer) }
          .to have_enqueued_job(ImportCsvUpdateOrCreateResultTaxonJob)
          .exactly(0).times
      end
    end
  end

  describe('#update_or_create_result_taxon') do
    include ProcessEdnaResults

    def subject(taxonomy_string, attributes)
      dummy_class.update_or_create_result_taxon(taxonomy_string, attributes)
    end

    let(:source_data) { '1|primer1' }

    shared_examples 'ResultTaxon matches taxa string' do |taxa_string|
      it 'does not create a ResultTaxon' do
        create(:result_taxon, original_taxonomy_string: [taxa_string],
                              clean_taxonomy_string: clean_string,
                              result_sources: [source_data])

        expect { subject(taxa_string, source_data) }
          .to change { ::ResultTaxon.count }.by(0)
      end

      context 'and source data is new' do
        it 'appends source data' do
          old_source = '2|primer2'
          taxon =
            create(:result_taxon, original_taxonomy_string: [taxa_string],
                                  clean_taxonomy_string: clean_string,
                                  result_sources: [old_source])

          expect { subject(taxa_string, source_data) }
            .to change { taxon.reload.result_sources }
            .from([old_source])
            .to([old_source, source_data])
        end
      end

      context 'and source data already exists' do
        it 'does not append source data' do
          taxon =
            create(:result_taxon, original_taxonomy_string: [taxa_string],
                                  clean_taxonomy_string: clean_string,
                                  result_sources: [source_data])

          expect { subject(taxa_string, source_data) }
            .to_not(change { taxon.reload.result_sources })
        end
      end

      context 'and taxonomy_string is new' do
        it 'appends original_taxonomy_string' do
          old_string = 'v1_string'
          taxon =
            create(:result_taxon, original_taxonomy_string: [old_string],
                                  clean_taxonomy_string: clean_string,
                                  result_sources: [source_data])

          expect { subject(taxa_string, source_data) }
            .to change { taxon.reload.original_taxonomy_string }
            .from([old_string])
            .to([old_string, taxa_string])
        end
      end

      context 'and taxonomy_string already exists' do
        it 'does not append original_taxonomy_string' do
          taxon =
            create(:result_taxon, original_taxonomy_string: [taxa_string],
                                  clean_taxonomy_string: clean_string,
                                  result_sources: [source_data])

          expect { subject(taxa_string, source_data) }
            .to_not(change { taxon.reload.original_taxonomy_string })
        end
      end
    end

    shared_examples "ResultTaxon don't match valid taxa string" do |options|
      let(:taxa_string) { options[:taxa_string] }
      let(:hierarchy) { options[:hierarchy] }
      let(:name) { options[:name] }
      let(:rank) { options[:rank] }
      let(:clean_string) { dummy_class.remove_na(taxa_string) }
      let(:result_taxon_common_attributes) do
        {
          canonical_name: name,
          taxon_rank: rank,
          hierarchy: hierarchy,
          original_taxonomy_string: [taxa_string],
          clean_taxonomy_string: clean_string
        }
      end

      it 'creates a ResultTaxon' do
        expect { subject(taxa_string, source_data) }
          .to change { ::ResultTaxon.count }.by(1)
      end

      context 'and matching NcbiNode is found' do
        let!(:ncbi_version_id) { create(:ncbi_version, id: 1).id }
        let(:ncbi_id) { 20 }
        let(:bold_id) { 30 }

        it 'creates a ResultTaxon with NcbiNode data' do
          taxon = create(:ncbi_node, hierarchy_names: hierarchy,
                                     rank: rank,
                                     canonical_name: name,
                                     ncbi_id: ncbi_id,
                                     bold_id: bold_id,
                                     ncbi_version_id: ncbi_version_id)

          attributes = {
            taxon_id: taxon.taxon_id,
            ncbi_id: taxon.ncbi_id,
            bold_id: taxon.bold_id,
            ncbi_version_id: taxon.ncbi_version_id,
            normalized: true,
            exact_match: true
          }
          result_taxon_attributes =
            result_taxon_common_attributes.merge(attributes)
                                          .with_indifferent_access

          results = subject(taxa_string, source_data)

          expect(results.attributes).to include(result_taxon_attributes)
        end
      end

      context 'and matching ncbi taxa is not found' do
        it 'creates a ResultTaxon with null ids' do
          attributes = {
            taxon_id: nil,
            ncbi_id: nil,
            bold_id: nil,
            ncbi_version_id: nil,
            normalized: false,
            exact_match: false
          }
          result_taxon_attributes =
            result_taxon_common_attributes.merge(attributes)
                                          .with_indifferent_access

          results = subject(taxa_string, source_data)

          expect(results.attributes).to include(result_taxon_attributes)
        end
      end
    end

    shared_examples "ResultTaxon don't match invalid taxa string" do |options|
      let(:taxa_string) { options[:taxa_string] }
      let(:hierarchy) { options[:hierarchy] }
      let(:name) { options[:name] }
      let(:rank) { options[:rank] }
      let(:clean_string) { dummy_class.remove_na(taxa_string) }
      let(:result_taxon_common_attributes) do
        {
          canonical_name: name,
          taxon_rank: rank,
          hierarchy: hierarchy,
          original_taxonomy_string: [taxa_string],
          clean_taxonomy_string: clean_string
        }
      end

      it 'creates a ResultTaxon' do
        expect { subject(taxa_string, source_data) }
          .to change { ::ResultTaxon.count }.by(1)
      end

      it 'creates a ResultTaxon with null ids' do
        attributes = {
          taxon_id: nil,
          ncbi_id: nil,
          bold_id: nil,
          ncbi_version_id: nil,
          normalized: false,
          exact_match: false
        }
        result_taxon_attributes =
          result_taxon_common_attributes.merge(attributes)
                                        .with_indifferent_access

        results = subject(taxa_string, source_data)

        expect(results.attributes).to include(result_taxon_attributes)
      end
    end

    context 'when taxonomy_string is combination of NA and ;;' do
      taxa_string = 'NA;;;NA;NA;'
      options = {
        hierarchy: {},
        name: ';;;;;',
        rank: 'unknown',
        taxa_string: taxa_string
      }

      include_examples 'ResultTaxon matches taxa string', taxa_string
      include_examples "ResultTaxon don't match invalid taxa string", options
    end

    context 'when taxonomy_string is NA' do
      taxa_string = 'NA'
      options = {
        hierarchy: {},
        name: 'NA',
        rank: 'unknown',
        taxa_string: taxa_string
      }

      include_examples 'ResultTaxon matches taxa string', taxa_string
      include_examples "ResultTaxon don't match invalid taxa string", options
    end

    context 'when taxonomy string is phylum format' do
      taxa_string = 'P;C;O;NA;G;S'
      options = {
        hierarchy: { phylum: 'P', class: 'C', order: 'O',
                     genus: 'G', species: 'S' },
        name: 'S',
        rank: 'species',
        taxa_string: taxa_string
      }

      include_examples 'ResultTaxon matches taxa string', taxa_string
      include_examples "ResultTaxon don't match valid taxa string", options
    end

    context 'when taxonomy string is superkingdom format' do
      taxa_string = 'SK;P;C;O;NA;G;S'
      options = {
        hierarchy: { superkingdom: 'SK', phylum: 'P', class: 'C', order: 'O',
                     genus: 'G', species: 'S' },
        name: 'S',
        rank: 'species',
        taxa_string: taxa_string
      }

      include_examples 'ResultTaxon matches taxa string', taxa_string
      include_examples "ResultTaxon don't match valid taxa string", options
    end
  end
end
