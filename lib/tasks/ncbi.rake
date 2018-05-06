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
end
