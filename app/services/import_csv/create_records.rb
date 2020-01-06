# frozen_string_literal: true

module ImportCsv
  module CreateRecords
    include CustomCounter
    include ProcessEdnaResults

    def create_asv(attributes)
      asv = Asv.where(attributes).first_or_create

      return asv if asv.valid?
      raise ImportError, "ASV #{attributes[:sample_id]}: #{asv.errors}"
    end

    def create_research_project_source(sourceable_id, type, research_project_id)
      attributes = {
        sourceable_id: sourceable_id,
        sourceable_type: type,
        research_project_id: research_project_id
      }

      project = ResearchProjectSource.where(attributes).first_or_create

      return if project.valid?
      raise ImportError, 'ResearchProjectSource not created'
    end

    def create_cal_taxon(data)
      CalTaxon.create(data)
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
