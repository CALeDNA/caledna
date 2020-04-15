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

  # https://rubyinrails.com/2019/07/12/postgres-reset-sequence-to-max-id-in-rails/
  task reset_sequence: :environment do
    conn.tables.each do |table|
      puts table
      conn.reset_pk_sequence!(table)
    end
  end

  def truncate(table)
    sql = "TRUNCATE TABLE #{table} RESTART IDENTITY CASCADE;"

    conn.exec_query(sql)
  end

  def conn
    @conn ||= ActiveRecord::Base.connection
  end
end