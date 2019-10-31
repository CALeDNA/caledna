# frozen_string_literal: true

module ImportCsv
  module EdnaResultsMetadata
    require 'csv'
    include CsvUtils

    def import_csv(file, research_project_id)
      delimiter = delimiter_detector(file)
      csv_data = CSV.read(file.path, headers: true, col_sep: delimiter)

      save_metadata(csv_data.first, research_project_id)
      create_appendix_page(research_project_id)
      OpenStruct.new(valid?: true, errors: nil)
    end

    private

    def save_metadata(row, research_project_id)
      project = ResearchProject.find(research_project_id)

      project.reference_barcode_database = row['reference_barcode_database']
      project.dryad_link = row['Dryad_link']
      project.decontamination_method = row['decontamination_method']
      project.primers = row['primers']
      project.metadata = row.to_h
      project.save
    end

    def create_appendix_page(research_project_id)
      page = Page.where(research_project_id: research_project_id)
                 .where(slug: 'appendix')
      return if page.present?

      Page.create(title: 'Appendix', slug: 'appendix', published: true,
                  body: '', research_project_id: research_project_id)
    end
  end
end
