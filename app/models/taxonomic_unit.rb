# frozen_string_literal: true

class TaxonomicUnit < ApplicationRecord
  has_one :hierarchy, foreign_key: 'tsn'
  belongs_to :kingdom
  has_one :longname, foreign_key: 'tsn'
  has_many :vernaculars, foreign_key: 'tsn'
  has_many :specimens, foreign_key: 'tsn'
  has_one :taxon_unit_type, foreign_key: 'rank_id'

  scope :valid, -> { where(n_usage: 'valid').or(where(n_usage: 'accepted')) }

  def common_name
    names = vernaculars.where(language: 'English').pluck(:vernacular_name)
    "(#{names.join(', ')})" if names.present?
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def taxonomy_tree
    return [] if hierarchy.blank?
    ids = hierarchy.hierarchy_string.split('-').map(&:to_i)
    ids_string = ids.join(', ')

    sql =
      'SELECT DISTINCT(taxonomic_units.tsn), complete_name, ' \
      'taxonomic_units.tsn, taxonomic_units.rank_id, ' \
      'rank_name, vernacular_name ' \
      'FROM taxonomic_units ' \
      'INNER JOIN taxon_unit_types ' \
      'ON taxonomic_units.rank_id = taxon_unit_types.rank_id ' \
      'LEFT JOIN vernaculars ' \
      'ON vernaculars.tsn = taxonomic_units.tsn ' \
      "WHERE taxonomic_units.tsn IN (#{ids_string}) " \
      "AND (language = 'English' OR language IS NULL)"

    taxa = ActiveRecord::Base.connection.execute(sql)
    puts taxa

    ids.map do |id|
      records = taxa.select { |taxon| taxon['tsn'] == id.to_i }

      record = records.first
      if records.pluck('vernacular_name').present?
        record['vernacular_name'] = records.pluck('vernacular_name').join(', ')
      end
      record
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
end
