# frozen_string_literal: true

class PgConnect
  # rubocop:disable Metrics/MethodLength
  def self.execute(sql, params = nil)
    db_string = if Rails.env.production?
                  'DATABASE_URL'
                elsif Rails.env.testing?
                  'DATABASE_TEST'
                else
                  'DATABASE_DEV'
                end
    begin
      con = PG.connect(ENV.fetch(db_string))
      if params.present?
        con.exec_params(sql, params)
      else
        con.exec(sql)
      end
    rescue PG::Error => e
      puts e.message
    ensure
      con&.close
    end
  end
  # rubocop:enable Metrics/MethodLength
end
