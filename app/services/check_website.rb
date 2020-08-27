# frozen_string_literal: true

module CheckWebsite
  def self.caledna_site?
    Website.default_site.name == 'CALeDNA'
  end

  def self.pour_site?
    Website.default_site.name == 'Protecting Our River'
  end
end
