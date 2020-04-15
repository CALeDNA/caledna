# frozen_string_literal: true

require 'rails_helper'

describe 'ImportCsvFirstOrCreateResearchProjSourceJob', type: :job do
  let(:subject) { ImportCsvFirstOrCreateResearchProjSourceJob }
  let(:research_project) { create(:research_project) }

  it 'creates a ResearchProjectSource when it does not exist' do
    sample = create(:sample, barcode: 'K0001-LA-S1')

    expect { subject.perform_now(sample, 'Sample', research_project.id) }
      .to change { ResearchProjectSource.count }.by(1)
  end

  it 'does not create a ResearchProjectSource when it does exist' do
    sample = create(:sample, barcode: 'K0001-LA-S1')
    create(:research_project_source, research_project: research_project,
                                     sourceable: sample)

    expect { subject.perform_now(sample, 'Sample', research_project.id) }
      .to change { ResearchProjectSource.count }.by(0)
  end
end
