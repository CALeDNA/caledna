# frozen_string_literal: true

require 'rails_helper'

describe ImportCsvCreateResearchProjectSourceJob, type: :job do
  let(:subject) { ImportCsvCreateResearchProjectSourceJob }
  let(:research_project) { create(:research_project) }

  it 'creates a ResearchProjectSource' do
    sample = create(:sample, barcode: 'K0001-LA-S1')

    expect { subject.perform_now(sample, 'Sample', research_project.id) }
      .to change { ResearchProjectSource.count }.by(1)
  end
end
