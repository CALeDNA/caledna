# frozen_string_literal: true

namespace :wikidata do
  desc 'import wikidata'
  task create_external_resources: :environment do
    require_relative '../../app/services/wikidata_import'
    include WikidataImport

    # sql = "DELETE FROM external_resources WHERE source = 'wikidata'"
    # conn.exec_query(sql)

    import_records
  end

  task add_wiki_excerpt: :environment do
    include WikipediaImport

    save_wiki_excerpts
  end
end
