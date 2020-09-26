# frozen_string_literal: true

namespace :wikidata do
  desc 'import wikidata'
  task import: :environment do
    require_relative '../../app/services/wikidata_import'
    include WikidataImport

    # sql = "DELETE FROM external_resources WHERE source = 'wikidata'"
    # conn.exec_query(sql)

    import_records
  end
end
