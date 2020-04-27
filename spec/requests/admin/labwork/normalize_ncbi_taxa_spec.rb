# frozen_string_literal: true

require 'rails_helper'

describe 'NormalizeNcbiTaxaController' do
  before { login_researcher }
  let(:ncbi_id) { 1000 }
  let(:bold_id) { 2000 }
  let(:taxon_id_n) { 1 }
  let(:taxon_id_b) { 2 }
  let(:ncbi_version_id) { 100 }
  let(:result_taxon_id) { 300 }
  let(:result_taxon) do
    create(:result_taxon, taxon_id: nil, canonical_name: 'name',
                          hierarchy: {}, id: result_taxon_id)
  end

  describe '#GET index' do
    it 'returns 200' do
      get admin_labwork_normalize_ncbi_taxa_path

      expect(response.status).to eq(200)
    end
  end

  describe '#GET show' do
    it 'returns 200' do
      get admin_labwork_normalize_ncbi_taxon_path(result_taxon)

      expect(response.status).to eq(200)
    end
  end

  describe '#PUT update_with_id' do
    before do
      create(:ncbi_version, id: ncbi_version_id)
      create(:ncbi_node, taxon_id: taxon_id_n, ncbi_id: ncbi_id,
                         source: 'NCBI', ncbi_version_id: ncbi_version_id)
      create(:ncbi_node, taxon_id: taxon_id_b, bold_id: bold_id, source: 'BOLD')
    end

    context 'when user enters in a valid NCBI id' do
      it 'updates ResultTaxon' do
        params = { normalize_ncbi_taxon:
          { source_id: ncbi_id, source: 'NCBI' } }
        rtaxon = result_taxon

        expect do
          put admin_labwork_normalize_ncbi_taxon_update_with_id_path(rtaxon),
              params: params
        end
          .to change { rtaxon.reload.taxon_id }
          .from(nil)
          .to(taxon_id_n)
          .and change { rtaxon.normalized }
          .to(true)
          .and change { rtaxon.ncbi_id }
          .to(ncbi_id)
          .and change { rtaxon.ncbi_version_id }
          .to(ncbi_version_id)
      end
    end

    context 'when user enters in a valid BOLD ID' do
      it 'updates ResultTaxon' do
        params = { normalize_ncbi_taxon:
          { source_id: bold_id, source: 'BOLD' } }
        rtaxon = result_taxon

        expect do
          put admin_labwork_normalize_ncbi_taxon_update_with_id_path(rtaxon),
              params: params
        end
          .to change { rtaxon.reload.taxon_id }
          .from(nil)
          .to(taxon_id_b)
          .and change { rtaxon.normalized }
          .to(true)
          .and change { rtaxon.normalized }
          .to(true)
          .and change { rtaxon.bold_id }
          .to(bold_id)
      end
    end

    context 'when user enters in an invalid id' do
      it 'does not update ResultTaxon taxon id' do
        params = { normalize_ncbi_taxon: { source_id: 999, source: 'NCBI' } }
        taxon = result_taxon

        expect do
          put admin_labwork_normalize_ncbi_taxon_update_with_id_path(taxon),
              params: params
        end
          .not_to(change { taxon.reload.taxon_id })
      end

      it 'redirects to show page' do
        params = { normalize_ncbi_taxon: { source_id: 999, source: 'NCBI' } }
        taxon = result_taxon
        put admin_labwork_normalize_ncbi_taxon_update_with_id_path(taxon),
            params: params

        expect(response.status).to eq(302)
        expect(response)
          .to redirect_to admin_labwork_normalize_ncbi_taxon_path(taxon)
      end
    end
  end

  # rubocop:disable Metrics/LineLength
  describe '#PUT update_with_suggestion' do
    before do
      create(:ncbi_version, id: ncbi_version_id)
      create(:ncbi_node, taxon_id: taxon_id_n, ncbi_id: ncbi_id,
                         source: 'NCBI', ncbi_version_id: ncbi_version_id,
                         bold_id: bold_id)
    end

    it 'updates ResultTaxon' do
      params = { normalize_ncbi_taxon:
        { taxon_id: taxon_id_n, ncbi_id: ncbi_id, bold_id: bold_id,
          ncbi_version_id: ncbi_version_id } }

      expect do
        put admin_labwork_normalize_ncbi_taxon_update_with_suggestion_path(result_taxon),
            params: params
      end
        .to change { result_taxon.reload.taxon_id }
        .from(nil)
        .to(taxon_id_n)
        .and change { result_taxon.normalized }
        .to(true)
        .and change { result_taxon.ncbi_id }
        .to(ncbi_id)
        .and change { result_taxon.bold_id }
        .to(bold_id)
        .and change { result_taxon.ncbi_version_id }
        .to(ncbi_version_id)
    end
  end
  # rubocop:enable Metrics/LineLength

  # rubocop:disable Metrics/LineLength
  describe '#PUT update_and_create_taxa' do
    let(:parent_taxon_id) { 3 }
    let(:division_id) { 400 }
    let(:cal_division_id) { 500 }
    let(:new_taxon_id) { 600 }
    let(:result_taxon_id) { 700 }

    let(:params) do
      {
        normalize_ncbi_taxon: {
          parent_taxon_id: parent_taxon_id,
          rank: 'phylum',
          canonical_name: 'name',
          result_taxon_id: result_taxon_id,
          division_id: division_id,
          cal_division_id: cal_division_id,
          ncbi_id: ncbi_id,
          bold_id: nil,
          source: 'NCBI',
          full_taxonomy_string: 'p_name|name',
          ncbi_version_id: ncbi_version_id,
          hierarchy_names: { phylum: 'name' },
          hierarchy: { phylum: new_taxon_id.to_s },
          ids: [parent_taxon_id, new_taxon_id],
          names: %w[p_name name],
          ranks: %w[phylym class]
        }
      }
    end

    before do
      create(:ncbi_version, id: ncbi_version_id)
    end

    context 'when matching NcbiNode does exist' do
      before do
        create(:ncbi_node, rank: 'phylum', canonical_name: 'name',
                           source: 'NCBI', ncbi_id: ncbi_id)
      end

      it 'does not create NcbiNode' do
        expect do
          put admin_labwork_normalize_ncbi_taxon_update_and_create_taxa_path(result_taxon),
              params: params
        end
          .to change { NcbiNode.count }.by(0)
      end

      it 'updates  NcbiNode with passed in values' do
        taxon = NcbiNode.first

        expect do
          put admin_labwork_normalize_ncbi_taxon_update_and_create_taxa_path(result_taxon),
              params: params
        end
          .to change { taxon.reload.parent_taxon_id }
          .to(parent_taxon_id)
          .and change { taxon.division_id }
          .to(division_id)
          .and change { taxon.cal_division_id }
          .to(cal_division_id)
          .and change { taxon.full_taxonomy_string }
          .to('p_name|name')
          .and change { taxon.hierarchy_names }
          .to('phylum' => 'name')
          .and change { taxon.hierarchy }
          .to('phylum' => new_taxon_id.to_s)
          .and change { taxon.ids }
          .to([parent_taxon_id, new_taxon_id])
          .and change { taxon.names }
          .to(%w[p_name name])
          .and change { taxon.ranks }
          .to(%w[phylym class])
      end
    end

    context 'when NcbiNode does not exist' do
      before do
        create(:ncbi_node)
      end

      it 'creates NcbiNode' do
        expect do
          put admin_labwork_normalize_ncbi_taxon_update_and_create_taxa_path(result_taxon),
              params: params
        end
          .to change { NcbiNode.count }.by(1)
      end

      it 'creates  NcbiNode with passed in values' do
        put admin_labwork_normalize_ncbi_taxon_update_and_create_taxa_path(result_taxon),
            params: params
        expected = params[:normalize_ncbi_taxon]
                   .except(:result_taxon_id, :update_result_taxa)
                   .with_indifferent_access

        expect(NcbiNode.first.attributes).to include(expected)
      end
    end

    context 'when update_result_taxa is true' do
      it 'updates ResultTaxon' do
        params[:normalize_ncbi_taxon][:update_result_taxa] = true

        expect do
          put admin_labwork_normalize_ncbi_taxon_update_and_create_taxa_path(result_taxon),
              params: params
        end
          .to change { result_taxon.reload.normalized }
          .to(true)
          .and change { result_taxon.ncbi_id }
          .to(ncbi_id)
      end

      it 'uses NcbiNode values to update ResultTaxon' do
        params[:normalize_ncbi_taxon][:update_result_taxa] = true

        put admin_labwork_normalize_ncbi_taxon_update_and_create_taxa_path(result_taxon),
            params: params

        taxon = NcbiNode.first
        result_taxon.reload

        expect(result_taxon.taxon_id).to eq(taxon.taxon_id)
        expect(result_taxon.ncbi_id).to eq(taxon.ncbi_id)
        expect(result_taxon.bold_id).to eq(taxon.bold_id)
        expect(result_taxon.ncbi_version_id).to eq(taxon.ncbi_version_id)
      end
    end

    context 'when update_result_taxa is false' do
      it 'does not update ResultTaxon' do
        params[:normalize_ncbi_taxon][:update_result_taxa] = false

        expect do
          put admin_labwork_normalize_ncbi_taxon_update_and_create_taxa_path(result_taxon),
              params: params
        end
          .to_not(change { result_taxon.reload.normalized })
      end
    end
  end
  # rubocop:enable Metrics/LineLength

  describe '#PUT ignore_taxon' do
    it 'updates ResultTaxon' do
      expect do
        put admin_labwork_normalize_ncbi_taxon_ignore_taxon_path(result_taxon)
      end
        .to change { result_taxon.reload.ignore }.to(true)
    end
  end
end
