# frozen_string_literal: true

module Admin
  module Tasks
    class AggregateCsvController < Admin::ApplicationController
      def index
        authorize 'Tasks::AggregateCsv'.to_sym, :index?

        @count = aggregate.completed_samples_count
        @files = aggregate.fetch_file_list('aggregate_csvs')
      end

      def create
        authorize 'Tasks::AggregateCsv'.to_sym, :create?

        create_csv
        flash[:success] = 'Creating CSVs.'
        redirect_to admin_labwork_import_csv_status_index_path
      end

      private

      def create_csv
        Primer.all.each do |primer|
          CreateAggregateTaxaCsvJob.perform_later(primer)
        end
        CreateAggregateSamplesCsvJob.perform_later
      end

      def aggregate
        @aggregate ||= AggregateCsv.new
      end
    end
  end
end
