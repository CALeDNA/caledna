# frozen_string_literal: true

class Extraction < ApplicationRecord
  METABARCODING_PRIMERS = %w[12s 16s 18s PITS FITS CO1 trnL cytB Other].freeze
  NUMBER_OF_REPLICATES = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9].freeze

  belongs_to :sample
  belongs_to :extraction_type
  belongs_to :processor, class_name: 'Researcher', foreign_key: 'processor_id',
                         optional: true
  belongs_to :sra_adder, class_name: 'Researcher', foreign_key: 'processor_id',
                         optional: true
  belongs_to :local_fastq_storage_adder, class_name: 'Researcher',
                                         foreign_key: 'processor_id',
                                         optional: true
  has_many :asvs
  has_many :research_projects

  as_enum :priority_sequencing, %i[none low high], map: :string
  as_enum :brand_beads, %i[AmpureXP Serapure Other], map: :string
  as_enum :select_indices, %i[Nextera Illumina], map: :string
  as_enum :index_brand_beads, %i[AmpureXP Serapure Other], map: :string
  as_enum :sequencing_platform, %i[HiSeq 2500 HiSeq4000 Miseq TruSeq],
          map: :string

  as_enum :status, %i[assigned analyzed results_completed],
          map: :string

  # validates :metabarcoding_primers, inclusion: { in: METABARCODING_PRIMERS }
  # validates :barcoding_pcr_number_of_replicates,
  #           inclusion: { in: NUMBER_OF_REPLICATES }

  def sorted_taxa
    asvs.map(&:taxon)
        .sort_by do |t|
          [
            t.kingdom, t.phylum, t.className, t.order, t.family, t.genus,
            t.specificEpithet, t.infraspecificEpithet
          ].compact
        end
  end
end
