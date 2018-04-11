# frozen_string_literal: true

module ImportCsv
  module DnaResults
    require 'csv'
    include ProcessTestResults

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def normalize_taxonomy(file)
      missing_taxonomy = []

      CSV.foreach(file.path, headers: true) do |row|
        taxonomy_string = row[row.headers.first]
        results = find_taxon_from_string(taxonomy_string)
        if results[:taxonID].blank? && results[:rank].present?
          missing_taxonomy.push(results)
          CalTaxon.create(
            taxonRank: results[:rank],
            original_hierarchy: results[:hierarchy],
            original_taxonomy: results[:taxonomy_string],
            normalized: false
          )
        end
      end

      if invalid_taxonomy.present?
        OpenStruct.new(valid?: false, errors: invalid_taxonomy)
      else
        OpenStruct.new(valid?: true, errors: [])
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def import_dna_results(file)
      extractions = {}
      sample_cells = []
      invalid_taxonomy = false

      CSV.foreach(file.path, headers: true) do |row|
        if extractions.empty?
          sample_cells = row.headers[1..row.headers.size]
          extractions = get_extractions_from_headers(sample_cells)
        end

        taxonomy_string = row[row.headers.first]
        taxon = find_taxon_from_string(taxonomy_string)
        if taxon.present? && taxon[:taxonID].present?
          # puts "========= valid taxonomy: #{taxon}"

          create_asvs(row, sample_cells, extractions, taxon)
        else
          invalid_taxonomy = true
          # invalid_taxonomy.push(taxonomy_string)
          puts "========= invalid taxonomy: #{taxonomy_string}"
        end
      end

      if invalid_taxonomy
        OpenStruct.new(valid?: false, errors: [])
      else
        OpenStruct.new(valid?: true, errors: [])
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    private

    def find_extraction(cell)
      # TODO: deal with different cell names
      sample = Sample.includes(:extractions).find_by(primer_pits: cell)
      return unless sample.present?

      extraction = sample.extractions.last
      if extraction.nil?
        extraction = Extraction.create(
          sample: sample,
          extraction_type: ExtractionType.first
        )
      end
      extraction
    end

    def get_extractions_from_headers(sample_cells)
      valid_extractions = {}
      sample_cells.each do |cell|
        extraction = find_extraction(cell)
        valid_extractions[cell] = extraction if extraction.present?
      end
      valid_extractions
    end

    def create_asvs(row, sample_cells, extractions, taxon)
      sample_cells.each do |cell|
        next if row[cell].to_i < 1
        extraction = extractions[cell]
        next if extraction.nil?
        puts "cell: #{cell}, extraction: #{extraction.id}, " \
             "taxon: #{taxon[:taxonID]}, count:  #{row[cell]}"
        Asv.create(extraction_id: extraction.id, taxonID: taxon[:taxonID])
      end
    end

    def create_demo_extraction(barcode)
      project = FieldDataProject.first
      sample = Sample.where(barcode: barcode, field_data_project: project)
                     .first_or_create
      Extraction.create(sample: sample, extraction_type: ExtractionType.first)
    end
  end
end

class ImportError < StandardError
end
