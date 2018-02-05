# frozen_string_literal: true

class TaxaController < ApplicationController
  def index
    @higlights = TaxonomicUnit.where(highlight: true).order(:complete_name)
    @top_taxa = TaxonomicUnit.where(tsn: top_taxa_ids)
  end

  def show
    @taxon = TaxonomicUnit.find(params[:id])
    @samples = Kaminari.paginate_array(samples).page(params[:page])
    @taxa = taxa
  end

  private

  def raw_samples
    sql = 'SELECT samples.id, bar_code, ' \
    'taxonomic_units.rank_id,  taxonomic_units.tsn as tsn, latitude, ' \
    'longitude, complete_name, project_id, name as project_name ' \
    'FROM taxonomic_units ' \
    'INNER JOIN hierarchy ON hierarchy.tsn = taxonomic_units.tsn ' \
    'INNER JOIN specimens ON hierarchy.tsn = specimens.tsn ' \
    'INNER JOIN samples ON specimens.sample_id = samples.id ' \
    'INNER JOIN projects ON samples.project_id = projects.id ' \
    "WHERE hierarchy_string ~ " \
    "'([^[:digit:]]|^)#{params[:id]}([^[:digit:]]|$)'"

    @raw_samples ||= ActiveRecord::Base.connection.execute(sql)
  end

  def samples
    groups = raw_samples.group_by {|t| t['id']}.values
    @samples ||= groups.map do |g|
      OpenStruct.new(g.first.merge(taxons: g.pluck('complete_name', 'tsn')))
    end
  end

  def taxa
    @taxa ||=
      TaxonomicUnit
      .distinct(:tsn)
      .joins(:hierarchy)
      .joins('INNER JOIN specimens ON hierarchy.tsn = specimens.tsn')
      .joins('INNER JOIN samples ON samples.id = specimens.sample_id')
      .where('hierarchy_string LIKE ?', "%#{params[:id]}%")
  end

  def top_taxa_ids
    Specimen.group('tsn').order('count(*) DESC').limit(10).pluck(:tsn)
  end

  def query_string
    query = {}
    query[:project_id] = params[:project_id] if params[:project_id]
    query
  end
end
