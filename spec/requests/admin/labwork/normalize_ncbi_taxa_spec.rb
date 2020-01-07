# frozen_string_literal: true

require 'rails_helper'

describe 'NormalizeNcbiTaxaController' do
  before { login_researcher }

  describe '#PUT update_with_id' do
    before do
      create(:ncbi_node, taxon_id: taxon_id_n, ncbi_id: ncbi_id)
      create(:ncbi_node, taxon_id: taxon_id_b, bold_id: bold_id)
    end
    let(:ncbi_id) { 1000 }
    let(:bold_id) { 2000 }
    let(:taxon_id_n) { 1 }
    let(:taxon_id_b) { 2 }
    let(:cal_taxon) { create(:cal_taxon, taxon_id: nil) }

    context 'when user enters in a valid NCBI id' do
      it 'updates CalTaxon taxon id' do
        params = { normalize_ncbi_taxon:
          { source_id: ncbi_id, source: 'NCBI' } }

        expect do
          put admin_labwork_normalize_ncbi_taxon_update_with_id_path(cal_taxon),
              params: params
        end
          .to change { cal_taxon.reload.taxon_id }
          .from(nil)
          .to(taxon_id_n)
      end
    end

    context 'when user enters in a valid BOLD ID' do
      it 'updates CalTaxon taxon id' do
        params = { normalize_ncbi_taxon:
          { source_id: bold_id, source: 'BOLD' } }

        expect do
          put admin_labwork_normalize_ncbi_taxon_update_with_id_path(cal_taxon),
              params: params
        end
          .to change { cal_taxon.reload.taxon_id }
          .from(nil)
          .to(taxon_id_b)
      end
    end

    context 'when user enters in an invalid id' do
      it 'does not update CalTaxon taxon id' do
        params = { normalize_ncbi_taxon: { source_id: 999, source: 'NCBI' } }

        expect do
          put admin_labwork_normalize_ncbi_taxon_update_with_id_path(cal_taxon),
              params: params
        end
          .not_to(change { cal_taxon.reload.taxon_id })
      end

      it 'redirects to show page' do
        params = { normalize_ncbi_taxon: { source_id: 999, source: 'NCBI' } }
        put admin_labwork_normalize_ncbi_taxon_update_with_id_path(cal_taxon),
            params: params

        expect(response.status).to eq(302)
        expect(response)
          .to redirect_to admin_labwork_normalize_ncbi_taxon_path(cal_taxon)
      end
    end
  end
end
