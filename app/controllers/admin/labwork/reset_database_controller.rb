# frozen_string_literal: true

module Admin
  module Labwork
    class ResetDatabaseController < Admin::ApplicationController
      def delete_data
        raise ReseedNotAllowedError if Rails.env.production?
        raise ReseedNotAllowedError unless current_researcher.director?

        truncate_tables
        reset_primary_keys
        ExtractionType.create(name: 'default')

        flash[:success] = 'Labwork data deleted'
        redirect_to admin_root_path
      end

      private

      def truncate_tables
        models.each do |model|
          ActiveRecord::Base.connection.execute("TRUNCATE #{model.table_name}")
        end
      end

      def reset_primary_keys
        models.each do |model|
          next if model == CalTaxon
          ActiveRecord::Base.connection.reset_pk_sequence!(model.table_name)
        end

        sql = 'ALTER SEQUENCE cal_taxa_taxonID_seq  RESTART WITH 2000000000;'
        ActiveRecord::Base.connection.execute(sql)
        sql = 'ALTER TABLE cal_taxa ALTER "taxonID" SET DEFAULT ' \
          'NEXTVAL(\'cal_taxa_taxonID_seq\');'
        ActiveRecord::Base.connection.execute(sql)
      end

      def models
        [
          Asv, ResearchProjectExtraction, Extraction,
          ExtractionType, CalTaxon
        ]
      end
    end
  end
end

class ReseedNotAllowedError < StandardError
end
