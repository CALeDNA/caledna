# frozen_string_literal: true

FactoryBot.define do
  factory :extraction do
    trait :processing_sample do
      sample
      extraction_type

      priority_sequencing false
      sequence(:sra_url) { |n| "http://example.com/sra_#{n}" }
      sra_add_date Time.zone.now
      sequence(:local_fastq_storage_url) { |n| "http://example.com/fastq_#{n}" }
      local_fastq_storage_add_date Time.zone.now
      stat_bio_reps_pooled true
      stat_bio_reps_pooled_date Time.zone.now
      loc_bio_reps_pooled { Faker::Lorem.words(2).join(' ') }
      bio_reps_pooled_date Time.zone.now
      protocol_bio_reps_pooled { Faker::Lorem.words(2).join(' ') }
      changes_protocol_bio_reps_pooled { Faker::Lorem.words(2).join(' ') }
    end

    trait :results_completed do
      sample
      extraction_type

      priority_sequencing false
      sequence(:sra_url) { |n| "http://example.com/sra_#{n}" }
      sra_add_date Time.zone.now
      sequence(:local_fastq_storage_url) { |n| "http://example.com/fastq_#{n}" }
      local_fastq_storage_add_date Time.zone.now
      stat_bio_reps_pooled true
      stat_bio_reps_pooled_date Time.zone.now
      loc_bio_reps_pooled { Faker::Lorem.words(2).join(' ') }
      bio_reps_pooled_date Time.zone.now
      protocol_bio_reps_pooled { Faker::Lorem.words(2).join(' ') }
      changes_protocol_bio_reps_pooled { Faker::Lorem.words(2).join(' ') }
      stat_dna_extraction true
      stat_dna_extraction_date Time.zone.now
      loc_dna_extracts { Faker::Lorem.words(2).join(' ') }
      dna_extraction_date Time.zone.now
      protocol_dna_extraction { Faker::Lorem.words(2).join(' ') }
      changes_protocol_dna_extraction { Faker::Lorem.words(2).join(' ') }
      metabarcoding_primers { Extraction::METABARCODING_PRIMERS.sample }
      stat_barcoding_pcr_done true
      stat_barcoding_pcr_done_date Time.zone.now
      barcoding_pcr_number_of_replicates 1
      reamps_needed { Faker::Lorem.words(2).join(' ') }
      stat_barcoding_pcr_pooled true
      stat_barcoding_pcr_pooled_date Time.zone.now
      stat_barcoding_pcr_bead_cleaned true
      stat_barcoding_pcr_bead_cleaned_date Time.zone.now
      brand_beads_cd { Extraction.brand_beads.keys.sample }
      cleaned_concentration { Faker::Number.decimal(2) }
      loc_stored { Faker::Lorem.words(2).join(' ') }
      select_indices_cd { Extraction.select_indices.keys.sample }
      index_1_name { Faker::Lorem.words(2).join(' ') }
      index_2_name { Faker::Lorem.words(2).join(' ') }
      stat_index_pcr_done true
      stat_index_pcr_done_date Time.zone.now
      stat_index_pcr_bead_cleaned true
      stat_index_pcr_bead_cleaned_date Time.zone.now
      index_brand_beads_cd { Extraction.brand_beads.keys.sample }
      index_cleaned_concentration { Faker::Number.decimal(2) }
      index_loc_stored { Faker::Lorem.words(2).join(' ') }
      stat_libraries_pooled true
      stat_libraries_pooled_date Time.zone.now
      loc_libraries_pooled { Faker::Lorem.words(2).join(' ') }
      stat_sequenced true
      stat_sequenced_date Time.zone.now
      intended_sequencing_depth_per_barcode { Faker::Lorem.words(2).join(' ') }
      sequencing_platform 'sequencing platform'
      assoc_field_blank { Faker::Lorem.words(2).join(' ') }
      assoc_extraction_blank { Faker::Lorem.words(2).join(' ') }
      assoc_pcr_blank { Faker::Lorem.words(2).join(' ') }
      sample_processor_notes { "Sample Processor. #{Faker::Lorem.paragraph}" }
      lab_manager_notes { "Lab Manager. #{Faker::Lorem.paragraph}" }
      director_notes { "Director. #{Faker::Lorem.paragraph}" }
    end
  end
end
