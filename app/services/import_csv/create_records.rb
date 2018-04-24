# frozen_string_literal: true

module ImportCsv
  module CreateRecords
    def create_asv(cell, extraction, taxon)
      asv = Asv.where(extraction_id: extraction.id, taxonID: taxon[:taxonID])
               .first_or_create
      raise ImportError, "ASV #{cell} not created" unless asv.valid?

      primer = convert_header_to_primer(cell)
      return if asv.primers.include?(primer)
      asv.primers << primer
      asv.save
    end

    def create_research_project_extraction(extraction, research_project_id)
      project =
        ResearchProjectExtraction
        .where(extraction: extraction,
               research_project_id: research_project_id)
        .first_or_create

      return if project.valid?
      raise ImportError, 'ResearchProjectExtraction not created'
    end

    private

    def convert_header_to_primer(cell)
      cell.split('_').first
    end
  end
end

class ImportError < StandardError
end
