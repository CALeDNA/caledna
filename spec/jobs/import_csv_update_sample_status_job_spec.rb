# frozen_string_literal: true

require 'rails_helper'

describe 'ImportCsvUpdateSampleStatusJob', type: :job do
  let(:subject) { ImportCsvUpdateSampleStatusJob }

  it 'creates a Update sample status when it does not exist' do
    sample = create(:sample, barcode: 'K0001-LA-S1', status_cd: nil)

    expect { subject.perform_now(sample.id) }
      .to change { sample.reload.status_cd }.from(nil).to('results_completed')
  end
end
