# frozen_string_literal: true

module CheckWebsite
  def self.caledna_site?
    Website::DEFAULT_SITE.name == 'CALeDNA'
  end

  def self.pour_site?
    Website::DEFAULT_SITE.name == 'Protecting Our River'
  end
end
