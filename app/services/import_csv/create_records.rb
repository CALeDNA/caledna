# frozen_string_literal: true

module ImportCsv
  module CreateRecords
    include ProcessingExtractions
    include CustomCounter

    def create_asv(cell, extraction, cal_taxon, count, primer)
      attributes = {
        extraction_id: extraction.id, sample: extraction.sample,
        taxonID: cal_taxon.taxonID
      }
      asv = Asv.where(attributes).first_or_create

      raise ImportError, "ASV #{cell}: #{asv.errors}" unless asv.valid?

      return if asv.primers.include?(primer)
      asv.primers << primer
      asv.counts[primer] = count
      asv.save
    end

    def create_research_project_source(sourceable, research_project_id)
      attributes = {
        sourceable: sourceable,
        research_project_id: research_project_id
      }
      if sourceable.is_a?(Extraction)
        attributes[:sample_id] = sourceable.sample.id
      end

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

    def create_raw_taxonomy_import(taxonomy_string, research_project_id,
                                   primer, notes)
      attributes = {
        taxonomy_string: taxonomy_string,
        research_project_id: research_project_id,
        primer: primer,
        notes: notes
      }
      raw_taxon = RawTaxonomyImport.where(attributes)
      return if raw_taxon.present?

      attributes[:name] = find_canonical_taxon_from_string(taxonomy_string)
      RawTaxonomyImport.create(attributes)
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
