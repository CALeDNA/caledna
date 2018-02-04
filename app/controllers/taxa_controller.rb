# frozen_string_literal: true

class TaxaController < ApplicationController
  def index
    @taxa = TaxonomicUnit.where(tsn: top_tsn)
  end

  def show
    @taxon = TaxonomicUnit.find(params[:id])
  end

  def top_tsn
    Specimen.group('tsn').order('count(*)')
            .limit(10).pluck(:tsn)
  end
end
