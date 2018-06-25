# frozen_string_literal: true

class PagesController < ApplicationController
  def show
    @page = Page.find_by(slug: params[:id])
  end
end
