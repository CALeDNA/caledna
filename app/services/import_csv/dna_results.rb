# frozen_string_literal: true

module ImportCsv
  # rubocop:disable Metrics/ModuleLength
  module DnaResults
    require 'csv'
    include ProcessTestResults

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def import_csv(file, research_project_id, extraction_type_id)
      extractions = {}
      sample_cells = []
      missing_taxonomy = 0

      CSV.foreach(file.path, headers: true) do |row|
        if extractions.empty?
          sample_cells = row.headers[1..row.headers.size]
          extractions = get_extractions_from_headers(
            sample_cells, research_project_id, extraction_type_id
          )
        end

        taxonomy_string = row[row.headers.first]
        taxon = find_taxon_from_string(taxonomy_string)
        if taxon.present? && taxon[:taxonID].present?
          create_asvs(row, sample_cells, extractions, taxon)
        else
          missing_taxonomy += 1
        end
      end

      if missing_taxonomy.zero?
        OpenStruct.new(valid?: true, errors: nil)
      else
        message = "#{missing_taxonomy} taxonomies were not imported " \
          'because no match was found.'
        OpenStruct.new(valid?: false, errors: message)
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    def convert_header_to_barcode(cell)
      sample = cell.split('_').last
      if /K\d{4}/.match?(sample)
        parts = sample.split('.')
        kit = parts.first
        location_letter = parts.second.split('').first
        sample_number = parts.second.split('').second
        "#{kit}-L#{location_letter}-S#{sample_number}"
      else
        sample.split('.').first
      end
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def find_sample(barcode)
      samples = Sample.includes(:extractions).where(barcode: barcode)

      if samples.count.zero?
        sample = Sample.create(
          barcode: barcode,
          status_cd: :missing_coordinates,
          field_data_project: FieldDataProject::DEFAULT_PROJECT
        )
        raise ImportError, "Sample #{barcode} not created" unless sample.valid?

      elsif samples.all?(&:rejected?) || samples.all?(&:duplicate_barcode?)
        raise ImportError, "Sample #{barcode} was previously rejected"
      elsif samples.count == 1
        sample = samples.first

        unless sample.missing_coordinates?
          sample.update(status_cd: :results_completed)
        end
      else
        temp_samples =
          samples.reject { |s| s.duplicate_barcode? || s.rejected? }

        if temp_samples.count > 1
          raise ImportError, "multiple samples with barcode #{barcode}"
        end

        sample = temp_samples.first

        unless sample.missing_coordinates?
          sample.update(status_cd: :results_completed)
        end
      end
      sample
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    private

    def convert_header_to_primer(cell)
      cell.split('_').first
    end

    def find_extraction(cell, extraction_type_id)
      barcode = convert_header_to_barcode(cell)
      sample = find_sample(barcode)

      extraction =
        Extraction
        .where(sample_id: sample.id, extraction_type_id: extraction_type_id)
        .first_or_create

      unless extraction.valid?
        raise ImportError, "Extraction #{barcode} not created"
      end
      extraction
    end

    # rubocop:disable Metrics/MethodLength
    def get_extractions_from_headers(
      sample_cells, research_project_id, extraction_type_id
    )
      valid_extractions = {}

      sample_cells.each do |cell|
        extraction = find_extraction(cell, extraction_type_id)
        valid_extractions[cell] = extraction
        project =
          ResearchProjectExtraction
          .where(extraction: extraction,
                 research_project_id: research_project_id)
          .first_or_create

        unless project.valid?
          raise ImportError, 'ResearchProjectExtraction not created'
        end
      end
      valid_extractions
    end
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def create_asvs(row, sample_cells, extractions, taxon)
      sample_cells.each do |cell|
        next if row[cell].to_i < 1

        extraction = extractions[cell]
        asv = Asv.where(extraction_id: extraction.id, taxonID: taxon[:taxonID])
                 .first_or_create
        raise ImportError, "ASV #{cell} not created" unless asv.valid?

        primer = convert_header_to_primer(cell)
        next if asv.primers.include?(primer)
        asv.primers << primer
        asv.save
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  end
  # rubocop:enable Metrics/ModuleLength
end

class ImportError < StandardError
end
