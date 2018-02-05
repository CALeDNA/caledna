# frozen_string_literal: true

class TaxaController < ApplicationController
  def index
    @taxa = TaxonomicUnit.where(tsn: top_tsn)
  end

  def show
    @taxon = TaxonomicUnit.find(params[:id])

    ids = Specimen.where(tsn: params[:id]).pluck(:sample_id)
    @samples = Sample.where(id: ids).page  params[:page]
  end

  def top_tsn
    Specimen.group('tsn').order('count(*)')
            .limit(10).pluck(:tsn)
  end
end
