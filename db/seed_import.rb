# frozen_string_literal: true

module SeedImport
  def import_taxonomy_data
    puts 'seeding taxonomy...'
    sql_file = Rails.root.join('db').join('data').join('gbif_data.sql')
    import_file(sql_file)
  end

  def import_taxa_datasets
    puts 'seeding taxa datasets...'
    sql_file = Rails.root.join('db').join('data').join('taxa_datasets_data.sql')
    import_file(sql_file)
  end

  def import_file(sql_file)
    host = ActiveRecord::Base.connection_config[:host]
    user = ActiveRecord::Base.connection_config[:username]
    db = ActiveRecord::Base.connection_config[:database]

    cmd = 'psql '
    cmd += "--host #{host} " if host.present?
    cmd += "--username #{user} " if user.present?
    cmd += "#{db} < #{sql_file}"
    exec cmd
  end
end
