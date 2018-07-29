# frozen_string_literal: true

class Extraction < ApplicationRecord
  METABARCODING_PRIMERS = %w[12s 16s 18s PITS FITS CO1 trnL cytB Other].freeze
  NUMBER_OF_REPLICATES = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9].freeze

  belongs_to :sample
  belongs_to :extraction_type, optional: true
  belongs_to :processor, class_name: 'Researcher', foreign_key: 'processor_id',
                         optional: true
  belongs_to :sra_adder, class_name: 'Researcher', foreign_key: 'sra_adder_id',
                         optional: true
  belongs_to :local_fastq_storage_adder,
             class_name: 'Researcher',
             foreign_key: 'local_fastq_storage_adder_id',
             optional: true
  has_many :asvs

  # https://github.com/rails/rails/issues/29123
  # NOTE: starting in rails 5.1, has_many must be before has_many through
  has_many :research_project_sources, as: :sourceable
  has_many :research_projects, through: :research_project_sources

  # TODO: decide what to do with priority_sequencing
  # as_enum :priority_sequencing, %i[none low high], map: :string
  as_enum :brand_beads, %i[AmpureXP Serapure Other], map: :string
  as_enum :select_indices, %i[Nextera Illumina], map: :string
  as_enum :index_brand_beads, %i[AmpureXP Serapure Other], map: :string
  as_enum :status, %i[assigned processing_sample results_completed],
          map: :string

  # validates :metabarcoding_primers, inclusion: { in: METABARCODING_PRIMERS }
  # validates :barcoding_pcr_number_of_replicates,
  #           inclusion: { in: NUMBER_OF_REPLICATES }
end
