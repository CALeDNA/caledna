# frozen_string_literal: true

module Admin
  module Labwork
    class ProcessExtractionsController < Admin::ApplicationController
      def index
        @extractions = Extraction.where(status_cd: :assigned).page params[:page]
      end

      def edit_multiple
        @extractions = Extraction.find(params[:batch_ids])
      end

      def update_multiple
        @extractions = Extraction.find(params[:batch_ids])
        @extractions.reject! do |extraction|
          extraction.update_attributes(update_params)
        end

        if @extractions.empty?
          redirect_to admin_labwork_path
        else
          @extraction = Extraction.new(update_params)
          render 'edit_multiple'
        end
      end

      private

      def update_params
        allowed_params.reject { |_, v| v.blank? }
      end

      # rubocop:disable Metrics/MethodLength
      def allowed_params
        params.require(:extraction).permit(
          :extraction_type_id,
          :priority_sequencing_cd,
          :prepub_share,
          :prepub_share_group,
          :prepub_filter_sensitive_info,
          :sra_url,
          :sra_adder_id,
          :sra_add_date,
          :local_fastq_storage_url,
          :local_fastq_storage_adder_id,
          :local_fastq_storage_add_date,
          :stat_bio_reps_pooled_date,
          :loc_bio_reps_pooled,
          :bio_reps_pooled_date,
          :protocol_bio_reps_pooled,
          :changes_protocol_bio_reps_pooled,
          :stat_dna_extraction_date,
          :loc_dna_extracts,
          :dna_extraction_date,
          :protocol_dna_extraction,
          :changes_protocol_dna_extraction,
          :metabarcoding_primers,
          :stat_barcoding_pcr_done_date,
          :barcoding_pcr_number_of_replicates,
          :reamps_needed,
          :stat_barcoding_pcr_pooled_date,
          :stat_barcoding_pcr_bead_cleaned_date,
          :brand_beads_cd,
          :cleaned_concentration,
          :loc_stored,
          :select_indices_cd,
          :index_1_name,
          :index_2_name,
          :stat_index_pcr_done_date,
          :stat_index_pcr_bead_cleaned_date,
          :index_brand_beads_cd,
          :index_cleaned_concentration,
          :index_loc_stored,
          :stat_libraries_pooled_date,
          :loc_libraries_pooled,
          :stat_sequenced_date,
          :intended_sequencing_depth_per_barcode,
          :sequencing_platform,
          :assoc_field_blank,
          :assoc_extraction_blank,
          :assoc_pcr_blank,
          :sample_processor_notes,
          :lab_manager_notes,
          :director_notes,
          :status_cd
        )
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
