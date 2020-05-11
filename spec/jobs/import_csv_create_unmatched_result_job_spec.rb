# frozen_string_literal: true

require 'rails_helper'

describe 'ImportCsvCreateUnmatchedResultJob', type: :job do
  let(:subject) { ImportCsvCreateUnmatchedResultJob }

  it 'creates a UnmatchedResult' do
    project = create(:research_project)
    primer = create(:primer)
    taxonomy_string = 'P;NA;NA;F;G;S'
    attributes = { primer_id: primer.id, research_project_id: project.id,
                   taxonomy_string: taxonomy_string }

    expect { subject.perform_now(taxonomy_string, attributes) }
      .to change { UnmatchedResult.count }.from(0).to(1)
  end

  it 'creates a UnmatchedResult using passed in data' do
    project = create(:research_project)
    primer = create(:primer)
    taxonomy_string = 'P;NA;NA;F;G;S'
    attributes = { primer_id: primer.id, research_project_id: project.id,
                   taxonomy_string: taxonomy_string }

    result = subject.perform_now(taxonomy_string, attributes)

    result.taxonomy_string = taxonomy_string
    result.clean_taxonomy_string = 'P;;;F;G;S'
    result.primer_id = primer.id
    result.research_project_id = project.id
    result.normalized = false
  end
end
