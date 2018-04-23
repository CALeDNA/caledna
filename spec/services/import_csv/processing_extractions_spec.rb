# frozen_string_literal: true

require 'rails_helper'
require 'csv'

describe ImportCsv::DnaResults do
  let(:dummy_class) { Class.new { extend ImportCsv::ProcessingExtractions } }

  describe '#find_researcher' do
    def subject(name)
      dummy_class.find_researcher(name)
    end

    it 'returns nil if name is "pending"' do
      name = 'PenDing'
      expect(subject(name)).to eq(nil)
    end

    context 'given name matches existing researcher' do
      it 'returns existing researcher' do
        name = 'Jane'
        researcher = create(:researcher, username: name)

        expect(subject(name)).to eq(researcher)
      end
    end

    context 'given name does not match existing researcher' do
      it 'creates new researcher' do
        name = 'Jane'
        create(:researcher, username: 'Jill')

        expect { subject(name) }.to change { Researcher.count }.by(1)
      end

      it 'returns newly created researcher' do
        name = 'Jane'
        create(:researcher, username: 'Jill')

        expect(subject(name)).to be_kind_of(Researcher)
        expect(subject(name).username).to eq(name)
      end
    end
  end

  describe('#process_boolean') do
    def subject(string)
      dummy_class.process_boolean(string)
    end

    it 'returns true if input is "yes"' do
      input = 'YeS'

      expect(subject(input)).to eq(true)
    end

    it 'returns true if input is "no"' do
      input = 'nO'

      expect(subject(input)).to eq(false)
    end

    it 'returns nil if input is random text' do
      input = 'abc'

      expect(subject(input)).to eq(nil)
    end
  end

  describe '#process_keyword_boolean' do
    def subject(string, keyword)
      dummy_class.process_keyword_boolean(string, keyword)
    end

    it 'returns true if input is "yes"' do
      keyword = 'abc'
      input = 'YeS'

      expect(subject(input, keyword)).to eq(true)
    end

    it 'returns true if input matches keyword' do
      keyword = 'abc'
      input = keyword

      expect(subject(input, keyword)).to eq(true)
    end

    it 'returns false if input is "no"' do
      keyword = 'abc'
      input = 'nO'

      expect(subject(input, keyword)).to eq(false)
    end

    it 'returns nil otherwise' do
      keyword = 'abc'
      input = 'cde'

      expect(subject(input, keyword)).to eq(nil)
    end
  end

  describe('#convert_date') do
    def subject(string)
      dummy_class.convert_date(string)
    end

    it 'returns nil if input is "pending"' do
      input = 'pending'

      expect(subject(input)).to eq(nil)
    end

    it 'returns nil if input is empty string' do
      input = nil

      expect(subject(input)).to eq(nil)
    end

    it 'returns "July 1" and year when passed in "Summer" and year' do
      input = 'SummEr 2018'
      expected = Time.parse('July 01, 2018')

      expect(subject(input)).to eq(expected)
    end

    it 'returns a date when given day, month, year' do
      input = '11-Apr-18'
      expected = Time.parse('April 11, 2018')

      expect(subject(input)).to eq(expected)
    end

    it 'returns a date when given a month and year' do
      input = 'Apr-18'
      expected = Time.parse('April 1, 2018')

      expect(subject(input)).to eq(expected)
    end

    it 'raises an error if given invalid date' do
      input = 'abc'

      expect { subject(input) }.to raise_error(ArgumentError, /no time info/)
    end
  end

  describe '#form_barcode' do
    def subject(string)
      dummy_class.form_barcode(string)
    end

    it 'returns a barcode when given a valid kit number with spaces' do
      string = 'K0001 B1'

      expect(subject(string)).to eq('K0001-LB-S1')
    end

    it 'returns a barcode when given a valid kit number w/o spaces' do
      string = 'K0001B1'

      expect(subject(string)).to eq('K0001-LB-S1')
    end

    it 'otherwise returns the original string' do
      string = 'abc'

      expect(subject(string)).to eq(string)
    end
  end

  describe('#import_csv') do
    before(:each) do
      project = create(:field_data_project, name: 'unknown')
      stub_const('FieldDataProject::DEFAULT_PROJECT', project)
    end

    def subject(file, extraction_type_id)
      dummy_class.import_csv(file, extraction_type_id)
    end

    let(:csv) { File.dirname(__FILE__) + '/processing_extraction.csv' }
    let(:file) { fixture_file_upload(csv, 'text/csv') }
    let(:extraction_type) { create(:extraction_type) }

    context 'when matching sample does not exists' do
      it 'creates sample & extraction' do
        create(:researcher, username: 'user1')

        expect { subject(file, extraction_type.id) }
          .to change { Sample.count }
          .by(1)
          .and change { Extraction.count }
          .by(1)
      end
    end

    context 'when matching extraction does not exists' do
      it 'creates extraction' do
        create(:researcher, username: 'user1')
        create(:sample, barcode: 'K0001-LA-S1')

        expect { subject(file, extraction_type.id) }
          .to change { Sample.count }
          .by(0)
          .and change { Extraction.count }
          .by(1)
      end
    end

    context 'when matching sample exists' do
      it 'does not create sample or extraction' do
        create(:researcher, username: 'user1')
        sample = create(:sample, barcode: 'K0001-LA-S1')
        create(:extraction, sample: sample, extraction_type: extraction_type)

        expect { subject(file, extraction_type.id) }
          .to change { Sample.count }
          .by(0)
          .and change { Extraction.count }
          .by(0)
      end

      it 'updates extraction fields with csv data' do
        user = create(:researcher, username: 'user1')
        sample = create(:sample, barcode: 'K0001-LA-S1')
        extraction = create(:extraction, sample: sample,
                                         extraction_type: extraction_type)
        date1 = Time.parse('1-Feb-18')
        date2 = Time.parse('July 2018')
        date3 = Time.parse('1-Jan-18')
        subject(file, extraction_type.id)
        extraction.reload
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
        expect(extraction.stat_bio_reps_pooled).to eq(true)
        expect(extraction.stat_bio_reps_pooled_date).to eq(date2)
        expect(extraction.loc_bio_reps_pooled).to eq('freezer')
        expect(extraction.bio_reps_pooled_date).to eq(date1)
        expect(extraction.protocol_bio_reps_pooled).to eq(nil)
        expect(extraction.changes_protocol_bio_reps_pooled).to eq(nil)
        expect(extraction.stat_dna_extraction).to eq(true)
        expect(extraction.stat_dna_extraction_date).to eq(date2)
        expect(extraction.loc_dna_extracts).to eq('freezer')
        expect(extraction.dna_extraction_date).to eq(date1)
        expect(extraction.protocol_dna_extraction).to eq(nil)
        expect(extraction.changes_protocol_dna_extraction).to eq(nil)
        expect(extraction.metabarcoding_primers).to eq(%w[a b c])
        expect(extraction.stat_barcoding_pcr_done).to eq(true)
        expect(extraction.stat_barcoding_pcr_done_date).to eq(date3)
        expect(extraction.barcoding_pcr_number_of_replicates).to eq(3)
        expect(extraction.reamps_needed).to eq('Yes PITS')
        expect(extraction.stat_barcoding_pcr_pooled).to eq(true)
        expect(extraction.stat_barcoding_pcr_pooled_date).to eq(date3)
        expect(extraction.stat_barcoding_pcr_bead_cleaned).to eq(true)
        expect(extraction.stat_barcoding_pcr_bead_cleaned_date).to eq(date1)
        expect(extraction.brand_beads_cd).to eq('Serapure')
        expect(extraction.cleaned_concentration).to eq('5 ng/µL')
        expect(extraction.loc_stored).to eq('freezer')
        expect(extraction.select_indices_cd).to eq(nil)
        expect(extraction.index_1_name).to eq('index_1')
        expect(extraction.index_2_name).to eq('index_2')
        expect(extraction.stat_index_pcr_done).to eq(true)
        expect(extraction.stat_index_pcr_done_date).to eq(date1)
        expect(extraction.stat_index_pcr_bead_cleaned).to eq(true)
        expect(extraction.stat_index_pcr_bead_cleaned_date).to eq(date1)
        expect(extraction.index_brand_beads_cd).to eq('Serapure')
        expect(extraction.index_cleaned_concentration).to eq('10 ng/µL')
        expect(extraction.index_loc_stored).to eq('freezer')
        expect(extraction.stat_libraries_pooled).to eq(true)
        expect(extraction.stat_libraries_pooled_date).to eq(date1)
        expect(extraction.loc_libraries_pooled).to eq('freezer')
        expect(extraction.stat_sequenced).to eq(true)
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
        expect(extraction.status_cd).to eq('results_completed')
      end
    end
  end
end
