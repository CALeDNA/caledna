# frozen_string_literal: true

module CustomPagination
  extend ActiveSupport::Concern

  private

  def add_pagination_methods(records)
    records.class.module_eval do
      attr_accessor :total_pages, :current_page, :limit_value
    end
    records.total_pages = total_pages
    records.current_page = page
    records.limit_value = limit
  end

  def conn
    @conn ||= ActiveRecord::Base.connection
  end

  def total_pages
    res = conn.execute(count_sql)
    total = res.getvalue(0, 0)
    (total.to_f / limit).ceil
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
