# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength:
namespace :ncbi do
  require_relative '../../app/services/format_ncbi'
  require_relative '../../app/services/process_test_results'

  include FormatNcbi
  include ProcessTestResults

  desc 'create canonical name'
  task create_canonical_name: :environment do
    puts 'create canonical name...'
    create_canonical_name
  end

  desc 'create alt_names'
  task create_alt_names: :environment do
    puts 'create alt_names...'
    create_alt_names
  end

  desc 'create lineage info'
  task create_lineage_info: :environment do
    puts 'create lineage info...'
    create_lineage_info
  end

  desc 'create citations nodes'
  task create_citations_nodes: :environment do
    puts 'create citations nodes...'
    create_citations_nodes
  end

  desc 'create taxonomy strings'
  task create_taxonomy_strings: :environment do
    puts 'create taxonomy strings...'
    create_taxonomy_strings
  end

  desc 'create ids'
  task create_ids: :environment do
    puts 'create ids...'
    create_ids
  end

  desc 'update cal_taxon'
  task update_cal_taxon: :environment do
    puts 'update cal_taxon...'
    CalTaxon.where(exact_gbif_match: false).all.each do |taxon|
      results = find_taxon_from_string_phylum(taxon.original_taxonomy)

      if results[:taxon_id].blank? && results[:rank].present?
        update_data = {
          taxonRank: results[:rank],
          original_hierarchy: results[:original_hierarchy],
          original_taxonomy: results[:original_taxonomy],
          complete_taxonomy: results[:complete_taxonomy],
          normalized: false,
          exact_gbif_match: false
        }
      elsif results[:taxon_id].present? && results[:rank].present?
        update_data = {
          taxonRank: results[:rank],
          original_hierarchy: results[:original_hierarchy],
          original_taxonomy: results[:original_taxonomy],
          complete_taxonomy: results[:complete_taxonomy],
          normalized: true,
          exact_gbif_match: true,
          taxonID: results[:taxon_id]
        }
      end

      taxon.attributes = update_data
      taxon.save(validate: false)
    end
  end
end
# rubocop:enable Metrics/BlockLength:
