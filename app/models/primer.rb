# frozen_string_literal: true

class Primer < ApplicationRecord
  after_save :expire_all_primers_cache
  before_destroy :expire_all_primers_cache

  ALL_PRIMERS_CACHE_KEY = 'all_primers'

  has_many :asvs
  has_many :sample_primers

  private

  def expire_all_primers_cache
    Rails.cache.delete(ALL_PRIMERS_CACHE_KEY)
  end
end
