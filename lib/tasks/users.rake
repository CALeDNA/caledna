# frozen_string_literal: true

namespace :users do
  task delete_spam_users: :environment do
    base_sql = 'DELETE FROM users where confirmed_at IS NULL AND '
    sqls = [
      "email ILIKE '%.ru'",
      "email ILIKE '%.ro'",
      "email ILIKE '%@thefmail.com'",
      "email ILIKE '%@yandex%'",
      "occupation IN ('Restaurant, food', 'Manufacturing, operations', " \
      "'Internet, new', 'Engineering, architecture', "\
      "'Education, training', 'Construction, facilities', " \
      "'Banking, mortgage', 'Enforcement, security', 'Advertising, public', " \
      "'Accounting, finance', 'Pharmaceutical, biotech', " \
      "'Clerical, administrative')"
    ]
    sqls.each do |sql|
      ActiveRecord::Base.connection.exec_query(base_sql + sql)
    end
  end
end
