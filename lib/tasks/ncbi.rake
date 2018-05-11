# frozen_string_literal: true

namespace :ncbi do
  require_relative '../../app/services/format_ncbi'
  include FormatNcbi

  desc 'insert canonical name'
  task insert_canonical_name: :environment do
    puts 'insert canonical name...'
    insert_canonical_name
  end

  desc 'update lineages'
  task update_lineages: :environment do
    puts 'update lineages...'
    update_lineages
  end

  desc 'create citations nodes'
  task create_citations_nodes: :environment do
    puts 'create citations nodes...'
    create_citations_nodes
  end

  desc 'create taxonomy strings'
  task create_taxonomy_strings: :environment do
    puts 'create taxonomy strings...'
    create_taxonomy_strings
  end
end
