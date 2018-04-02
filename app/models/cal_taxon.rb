# frozen_string_literal: true

class CalTaxon < ApplicationRecord
  after_create :update_hierarchy

  TAXON_RANK = %w[kingdom phylum class order family genus species].freeze
  TAXON_STATUS = ['accepted', 'doubtful', 'heterotypic synonym',
                  'homotypic synonym', 'synonym'].freeze

  validates :kingdom, :parentNameUsageID, :canonicalName, :taxonRank,
            :taxonomicStatus, presence: true
  validates :hierarchy, presence: true, on: :update
  validate :at_least_one_taxa
  validates :taxonomicStatus, inclusion: { in: TAXON_STATUS }
  validates :taxonRank, inclusion: { in: TAXON_RANK }
  validates :canonicalName, uniqueness: { scope: :kingdom }

  def update_hierarchy
    sql = 'UPDATE cal_taxa SET hierarchy = jsonb_set(hierarchy, ' \
          "'{#{taxonRank}}', '#{taxonID}'::jsonb) " \
          "WHERE \"taxonID\" = #{taxonID};"
    ActiveRecord::Base.connection.execute(sql)
  end

  private

  def at_least_one_taxa
    fields = [phylum, className, order, family, genus, specificEpithet]
    return if fields.any?(&:present?)
    errors.add(:at_least_one_taxa, ': At least one taxonomy field must be entered')
  end
end
