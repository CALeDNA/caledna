# frozen_string_literal: true

module Admin
  module Labwork
    class TaxaCountsController < Admin::ApplicationController
      include CustomCounter

      def taxa_asvs_count
        authorize 'Labwork::ImportCsv'.to_sym, :index?
      end

      def update_taxa_asvs_count
        authorize 'Labwork::ImportCsv'.to_sym, :index?

        ::FetchTaxaAsvsCountsJob.perform_later
        redirect_to admin_labwork_import_csv_status_index_path
      end

      def la_river_taxa_asvs_count
        authorize 'Labwork::ImportCsv'.to_sym, :index?
      end

      def update_la_river_taxa_asvs_count
        authorize 'Labwork::ImportCsv'.to_sym, :index?

        ::FetchLaRiverTaxaAsvsCountsJob.perform_later
        ::FetchTaxaAsvsCountsJob.perform_later
        redirect_to admin_labwork_import_csv_status_index_path
      end
    end
  end
end
