# frozen_string_literal: true

require 'rails_helper'

describe Page do
  describe 'validations' do
    describe '#unique_slugs' do
      before do
        stub_const('Website::DEFAULT_SITE', create(:website, name: 'demo'))
      end

      let(:site) { Website::DEFAULT_SITE }

      context 'when pages are for different sites' do
        it 'returns true if slug is unique to a site' do
          create(:page, slug: 'slug1', website: site)
          page = build(:page, slug: 'slug2', website: site)

          expect(page.valid?).to eq(true)
        end

        it 'returns false if slug is not unique to a site' do
          website = site
          create(:page, slug: 'slug', website: website)
          page = build(:page, slug: 'slug', website: website)

          expect(page.valid?).to eq(false)
          expect(page.errors.messages[:slug]).to eq(['has already been taken'])
        end
      end

      context 'when page is not for research project' do
        let(:website) { site }

        it 'returns true if slug is unique' do
          create(:page, slug: 'slug1', website: site)
          page = build(:page, slug: 'slug2', website: site)

          expect(page.valid?).to eq(true)
        end

        it 'returns false if slug is not unique' do
          create(:page, slug: 'slug', website: site)
          page = build(:page, slug: 'slug', website: site)

          expect(page.valid?).to eq(false)
          expect(page.errors.messages[:slug]).to eq(['has already been taken'])
        end
      end

      context 'when pages is updated' do
        it 'returns true if slug is unique' do
          page = create(:page, slug: 'slug1', website: site)
          page.update(body: 'body')

          expect(page.valid?).to eq(true)
        end
      end
    end
  end

  describe '#show_edit_link?' do
    let(:page) { create(:page) }

    it 'returns true if user is director' do
      user = create(:director)

      expect(page.show_edit_link?(user)).to eq(true)
    end

    it 'returns true if user is superadmin' do
      user = create(:superadmin)

      expect(page.show_edit_link?(user)).to eq(true)
    end

    it 'returns false researchers' do
      user = create(:researcher)

      expect(page.show_edit_link?(user)).to eq(false)
    end

    it 'returns false if no user' do
      user = nil

      expect(page.show_edit_link?(user)).to eq(false)
    end
  end
end
