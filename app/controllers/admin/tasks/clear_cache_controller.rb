
# frozen_string_literal: true

module Admin
  module Tasks
    class ClearCacheController < Admin::ApplicationController
      def index; end

      def update
        Rails.cache.delete(params[:clear_cache][:id])
        flash[:success] = 'Cache cleared'
        redirect_to admin_tasks_clear_cache_index_path
      end
    end
  end
end
