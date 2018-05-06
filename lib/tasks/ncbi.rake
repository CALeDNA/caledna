# frozen_string_literal: true

namespace :ncbi do
  require_relative '../../app/services/format_ncbi'
  include FormatNcbi

  desc 'insert canonical name'
  task insert_canonical_name: :environment do
    puts 'insert canonical name...'
    insert_canonical_name
  end
  end
end
