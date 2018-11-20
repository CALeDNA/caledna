# frozen_string_literal: true

namespace :cal_taxa do
  task update_missing_superkingdom_string: :environment do
    sql =  <<-SQL
    update cal_taxa
    set original_taxonomy_superkingdom =
      coalesce(original_hierarchy ->> 'superkingdom', '') ||
      ';' || original_taxonomy_phylum
    where cal_taxa.original_taxonomy_superkingdom is null;
    SQL

    ActiveRecord::Base.connection.execute(sql)
  end
end
