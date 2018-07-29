# frozen_string_literal: true

module ImportCsv
  module CreateRecords
    include ProcessingExtractions
    include CustomCounter

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def create_asv(cell, extraction, cal_taxon, count)
      attributes = {
        extraction_id: extraction.id, sample: extraction.sample,
        taxonID: cal_taxon.taxonID, count: count
      }
      asv = Asv.find_by(attributes)
      if asv.nil?
        asv = Asv.create(attributes)
        update_asvs_count(cal_taxon.taxonID)
      end

      raise ImportError, "ASV #{cell}: #{asv.errors}" unless asv.valid?

      primer = convert_header_to_primer(cell)
      return if primer.blank?
      return if asv.primers.include?(primer)
      asv.primers << primer
      asv.save
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def create_research_project_source(sourceable, research_project_id)
      attributes = {
        sourceable: sourceable,
        research_project_id: research_project_id
      }
      attributes[:sample] = sourceable.sample if sourceable.is_a?(Extraction)

      project = ResearchProjectSource.where(attributes).first_or_create

      return if project.valid?
      raise ImportError, 'ResearchProjectSource not created'
    end

    def update_extraction_details(extraction, extraction_type_id, row)
      hash = JSON.parse(row).to_h
      update_data = format_update_data(hash, extraction_type_id)
      extraction.update(clean_up_hash(update_data))
      extraction
    end

    def create_cal_taxon(data)
      CalTaxon.create(data)
    end

    def update_asvs_count(taxon_id)
      count = get_count(taxon_id)
      update_count(taxon_id, count)
    end

    private

    def convert_header_to_primer(cell)
      return unless cell.include?('_')
      cell.split('_').first
    end
  end
end

class ImportError < StandardError
end
