# frozen_string_literal: true

module Admin
  module Labwork
    class ImportCsvController < Admin::ApplicationController
      include ImportCsv::SampleCsv

      def samples; end

      def samples_create
        import_sample_csv(params[:file])
        redirect_to admin_root_path, notice: 'Samples imported.'
      end
    end
  end
end
