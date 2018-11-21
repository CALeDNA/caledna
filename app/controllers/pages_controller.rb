# frozen_string_literal: true

class PagesController < ApplicationController
  layout :resolve_layout

  def home
    @stats = {
      samples_approved: Sample.approved.with_coordinates.count,
      users: User::EXISTING_USERS + User.count,
      organisms: organism_count.first['count']
    }

    @page = Page.find_by(slug: :home)
  end

  def home_2
    @stats = {
      samples_approved: Sample.approved.count,
      users: User::EXISTING_USERS + User.count,
      organisms: organism_count.first['count']
    }

    @page_one = Page.find_by(slug: :home_2_1)
    @page_two = Page.find_by(slug: :home_2_2)
  end

  def show
    @page = Page.find_by(slug: params[:id])
  end

  def update
    page = Page.find(params[:id])
    if current_researcher && page.update(update_params)
      redirect_to research_projects_pillar_point_path(
        section: raw_params[:section]
      )
    else
      flash[:error] = 'Something went wrong. Changes not saved'
      redirect_to request.referrer
    end
  end

  private

  def update_params
    raw_params.except(:section)
  end

  def raw_params
    params.require(:page).permit(:body, :title, :section)
  end

  def organism_count
    sql = 'SELECT COUNT(DISTINCT("taxonID")) from asvs'
    @organism_count ||= ActiveRecord::Base.connection.execute(sql)
  end

  def resolve_layout
    case action_name
    when 'show'
      'application'
    else
      'home'
    end
  end
end
