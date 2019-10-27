# frozen_string_literal: true

module Admin
  module Labwork
    class ResetDatabaseController < Admin::ApplicationController
      # rubocop:disable Metrics/AbcSize
      def delete_labwork_data
        raise ReseedNotAllowedError if Rails.env.production?
        raise ReseedNotAllowedError unless current_researcher.director?

        truncate_tables(labwork_models)
        reset_primary_keys(labwork_models)

        set_cal_taxa_sequence
        ExtractionType.create(name: 'default')

        flash[:success] = 'Labwork data deleted'
        redirect_to admin_root_path
      end
      # rubocop:enable Metrics/AbcSize

      def delete_fieldwork_data
        raise ReseedNotAllowedError if Rails.env.production?
        raise ReseedNotAllowedError unless current_researcher.director?

        truncate_tables(fieldwork_models)
        reset_primary_keys(fieldwork_models)

        FieldProject.create(name: 'unknown')

        flash[:success] = 'fieldwork data deleted'
        redirect_to admin_root_path
      end

      private

      def truncate_tables(models)
        models.each do |model|
          ActiveRecord::Base.connection
                            .execute("TRUNCATE #{model.table_name} CASCADE")
        end
      end

      def reset_primary_keys(models)
        models.each do |model|
          next if model == CalTaxon
          ActiveRecord::Base.connection.reset_pk_sequence!(model.table_name)
        end
      end

      def set_cal_taxa_sequence
        sql = 'ALTER SEQUENCE cal_taxa_taxonID_seq  RESTART WITH 2000000000;'
        ActiveRecord::Base.connection.execute(sql)
        sql = 'ALTER TABLE cal_taxa ALTER "taxonID" SET DEFAULT ' \
          'NEXTVAL(\'cal_taxa_taxonID_seq\');'
        ActiveRecord::Base.connection.execute(sql)
      end

      def labwork_models
        [
          Asv, ResearchProjectSource, Extraction,
          ExtractionType, CalTaxon
        ]
      end

      def fieldwork_models
        [
          Photo, FieldProject, ResearchProject, Sample
        ]
      end
    end
  end
end

class ReseedNotAllowedError < StandardError
end
