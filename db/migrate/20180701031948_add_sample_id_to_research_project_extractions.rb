class AddSampleIdToResearchProjectExtractions < ActiveRecord::Migration[5.2]
  def up
    add_reference :research_project_extractions, :sample, type: :integer,
                  index: true
  end

  def down
    remove_reference :research_project_extractions, :sample
  end
end
