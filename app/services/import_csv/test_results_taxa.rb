# frozen_string_literal: true

module ImportCsv
  module TestResultsTaxa
    require 'csv'
    include ProcessTestResults
    include CsvUtils

    def import_csv(file)
      delimiter = delimiter_detector(file)

      CSV.foreach(file.path, headers: true, col_sep: delimiter) do |row|
        taxonomy_string = row[row.headers.first]
        ImportCsvFindCalTaxonJob.perform_later(taxonomy_string)
      end

      OpenStruct.new(valid?: true, errors: nil)
    end

    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/MethodLength, Metrics/PerceivedComplexity
    def find_cal_taxon(taxonomy_string)
      results = if phylum_taxonomy_string?(taxonomy_string)
                  find_taxon_from_string_phylum(taxonomy_string)
                else
                  find_taxon_from_string_superkingdom(taxonomy_string)
                end

      cal_taxon_phylum = cal_taxon(results[:original_taxonomy_phylum])
      return if cal_taxon_phylum.present?
      cal_taxon_superkingdom =
        cal_taxon(results[:original_taxonomy_superkingdom])
      return if cal_taxon_superkingdom.present?

      if results[:taxon_id].blank? && results[:rank].present?
        create_data = taxon_not_found(results)
      elsif results[:taxon_id].present? && results[:rank].present?
        create_data = taxon_found(results)
      end

      ImportCsvCreateCalTaxonJob.perform_later(create_data)
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/MethodLength, Metrics/PerceivedComplexity

    def cal_taxon(original_taxonomy)
      sql = 'original_taxonomy_phylum = ? OR ' \
        'original_taxonomy_superkingdom = ?'
      CalTaxon.where(sql, original_taxonomy, original_taxonomy).first
    end

    def taxon_not_found(results)
      {
        taxonRank: results[:rank],
        original_hierarchy: results[:original_hierarchy],
        original_taxonomy_phylum: results[:original_taxonomy_phylum],
        original_taxonomy_superkingdom:
          results[:original_taxonomy_superkingdom],
        complete_taxonomy: results[:complete_taxonomy],
        normalized: false,
        exact_gbif_match: false
      }
    end

    # rubocop:disable Metrics/MethodLength
    def taxon_found(results)
      {
        taxonRank: results[:rank],
        original_hierarchy: results[:original_hierarchy],
        original_taxonomy_phylum: results[:original_taxonomy_phylum],
        original_taxonomy_superkingdom:
          results[:original_taxonomy_superkingdom],
        complete_taxonomy: results[:complete_taxonomy],
        normalized: true,
        exact_gbif_match: true,
        taxonID: results[:taxon_id]
      }
    end
    # rubocop:enable Metrics/MethodLength
  end
end
