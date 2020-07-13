# frozen_string_literal: true

class ImportKoboSampleJob < ApplicationJob
  include KoboApi::Process

  queue_as :default

  def perform(project_id, kobo_id, sample_data)
    save_or_update_sample_data(project_id, kobo_id, sample_data)
  end
end
