# frozen_string_literal: true

namespace :wikidata do
  desc 'import wikidata'
  task import: :environment do
    require_relative '../../app/services/wikidata_import'
    include WikidataImport
    import_records
  end
end
