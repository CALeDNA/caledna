# frozen_string_literal: true

require 'rails_helper'

describe ImportCsvUpdateExtractionDetailsJob, type: :job do
  let(:subject) { ImportCsvUpdateExtractionDetailsJob }
  let(:extraction_type) { create(:extraction_type) }
  let(:research_project) { create(:research_project) }
  let(:csv) { './spec/fixtures/import_csv/processing_extraction.csv' }
  let(:file) { fixture_file_upload(csv, 'text/csv') }

  it 'updates an extraction' do
    user = create(:researcher, username: 'user1')
    sample = create(:sample, barcode: 'K0001-LA-S1')
    extraction = create(:extraction, sample: sample,
                                     extraction_type: extraction_type)
    date1 = Time.parse('1-Feb-18')
    date2 = Time.parse('July 2018')
    date3 = Time.parse('1-Jan-18')
    row = CSV.read(file.path, headers: true, col_sep: ',').first.to_json

    subject.perform_now(extraction, extraction_type.id, row)
    user2 = Researcher.second

    expect(extraction.extraction_type_id).to eq(extraction_type.id)
    expect(extraction.sum_taxonomy_example).to eq('X16S_K0001A1_S1_L001')
    expect(extraction.processor_id).to eq(user.id)
    expect(extraction.priority_sequencing).to eq(true)
    expect(extraction.prepub_share).to eq(false)
    expect(extraction.prepub_share_group).to eq('group')
    expect(extraction.prepub_filter_sensitive_info).to eq(nil)
    expect(extraction.sra_url).to eq('pending')
    expect(extraction.sra_adder_id).to eq(nil)
    expect(extraction.sra_add_date).to eq(nil)
    expect(extraction.local_fastq_storage_url).to eq('/full/path')
    expect(extraction.local_fastq_storage_adder_id).to eq(user2.id)
    expect(extraction.local_fastq_storage_add_date).to eq(date1)
    expect(extraction.stat_bio_reps_pooled_date).to eq(date2)
    expect(extraction.loc_bio_reps_pooled).to eq('freezer')
    expect(extraction.bio_reps_pooled_date).to eq(date1)
    expect(extraction.protocol_bio_reps_pooled).to eq(nil)
    expect(extraction.changes_protocol_bio_reps_pooled).to eq(nil)
    expect(extraction.stat_dna_extraction_date).to eq(date2)
    expect(extraction.loc_dna_extracts).to eq('freezer')
    expect(extraction.dna_extraction_date).to eq(date1)
    expect(extraction.protocol_dna_extraction).to eq(nil)
    expect(extraction.changes_protocol_dna_extraction).to eq(nil)
    expect(extraction.metabarcoding_primers).to eq(%w[a b c])
    expect(extraction.stat_barcoding_pcr_done_date).to eq(date3)
    expect(extraction.barcoding_pcr_number_of_replicates).to eq(3)
    expect(extraction.reamps_needed).to eq('Yes PITS')
    expect(extraction.stat_barcoding_pcr_pooled_date).to eq(date3)
    expect(extraction.stat_barcoding_pcr_bead_cleaned_date).to eq(date1)
    expect(extraction.brand_beads_cd).to eq('Serapure')
    expect(extraction.cleaned_concentration).to eq('5 ng/µL')
    expect(extraction.loc_stored).to eq('freezer')
    expect(extraction.select_indices_cd).to eq(nil)
    expect(extraction.index_1_name).to eq('index_1')
    expect(extraction.index_2_name).to eq('index_2')
    expect(extraction.stat_index_pcr_done_date).to eq(date1)
    expect(extraction.stat_index_pcr_bead_cleaned_date).to eq(date1)
    expect(extraction.index_brand_beads_cd).to eq('Serapure')
    expect(extraction.index_cleaned_concentration).to eq('10 ng/µL')
    expect(extraction.index_loc_stored).to eq('freezer')
    expect(extraction.stat_libraries_pooled_date).to eq(date1)
    expect(extraction.loc_libraries_pooled).to eq('freezer')
    expect(extraction.stat_sequenced_date).to eq(date1)
    expect(extraction.intended_sequencing_depth_per_barcode)
      .to eq('25,000 reads')
    expect(extraction.sequencing_platform).to eq('MiSeq 2x300')
    expect(extraction.assoc_field_blank).to eq(nil)
    expect(extraction.assoc_extraction_blank)
      .to eq('MIMGsprextneg_S15_L001')
    expect(extraction.assoc_pcr_blank).to eq('MIMGsprPCRneg_S16_L001')
    expect(extraction.sample_processor_notes)
      .to eq('sample processor notes')
    expect(extraction.lab_manager_notes).to eq('lab manager notes')
    expect(extraction.director_notes).to eq('director notes')
    expect(extraction.status_cd).to eq('processing_sample')
  end
end
