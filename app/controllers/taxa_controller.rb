# frozen_string_literal: true

class TaxaController < ApplicationController
  def index
    @higlights = TaxonomicUnit.where(highlight: true).order(:complete_name)
    @top_taxa = TaxonomicUnit.where(tsn: top_taxa_ids)
  end

  def show
    @taxon = TaxonomicUnit.find(params[:id])

    ids = Specimen.where(tsn: params[:id]).pluck(:sample_id)
    @samples = Sample.where(id: ids).page  params[:page]
  end

  private

  def top_taxa_ids
    Specimen.group('tsn').order('count(*) DESC').limit(10).pluck(:tsn)
  end
end
