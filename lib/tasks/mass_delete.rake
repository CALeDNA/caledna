# frozen_string_literal: true

namespace :mass_delete do
  task field_projects: :environment do
    return unless Rails.env.development?

    tables = %w[kobo_photos event_registrations events field_projects
                samples]
    tables.each do |table|
      truncate(table)
    end
  end

  task research_projects: :environment do
    return unless Rails.env.development?

    tables = %w[asvs research_project_authors pages research_project_sources
                research_projects researchers result_taxa]
    tables.each do |table|
      truncate(table)
    end
  end

  task truncate_samples_tables: :environment do
    return unless Rails.env.development?

    sqls = [
      'TRUNCATE asvs restart identity;',
      'TRUNCATE pages restart identity;',
      'TRUNCATE sample_primers restart identity;',
      'TRUNCATE result_taxa restart identity;',
      'TRUNCATE research_project_authors restart identity;',
      'TRUNCATE research_project_sources restart identity;',
      'TRUNCATE kobo_photos restart identity;',
      'TRUNCATE event_registrations restart identity;',
      'TRUNCATE events restart identity CASCADE;',
      'TRUNCATE research_projects restart identity CASCADE;',
      'TRUNCATE samples restart identity CASCADE;',
      'TRUNCATE field_projects restart identity CASCADE;'
    ]

    sqls.each do |sql|
      ActiveRecord::Base.connection.exec_query(sql)
    end
  end

  def truncate(table)
    return unless Rails.env.development?

    sql = "TRUNCATE TABLE #{table} RESTART IDENTITY CASCADE;"

    conn.exec_query(sql)
  end

  def conn
    @conn ||= ActiveRecord::Base.connection
  end
end
