# frozen_string_literal: true

module CustomPagination
  extend ActiveSupport::Concern

  private

  def add_pagination_methods(records)
    records.class.module_eval do
      attr_accessor :total_pages, :current_page, :limit_value, :total_records
    end
    records.total_pages = total_pages
    records.current_page = page
    records.limit_value = limit
    records.total_records = total_records
  end

  def conn
    @conn ||= ActiveRecord::Base.connection
  end

  def total_pages
    @total_pages ||= (total_records.to_f / limit).ceil
  end

  def total_records
    @total_records ||= begin
      res = conn.execute(count_sql)
      res.getvalue(0, 0)
    end
  end

  def limit
    25
  end

  def offset
    (page - 1) * limit
  end

  def page
    params[:page].present? ? params[:page].to_i : 1
  end
end
