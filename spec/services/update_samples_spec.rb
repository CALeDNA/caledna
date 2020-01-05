# frozen_string_literal: true

require 'rails_helper'

describe UpdateSamples do
  let(:dummy_class) { Class.new { extend UpdateSamples } }

  describe '#add_primers_from_asv' do
    def subject(asv)
      dummy_class.add_primers_from_asv(asv)
    end

    context 'sample does not have primers' do
      xit 'add one primer to sample from asv' do
        sample = create(:sample, primers: [])
        extraction = create(:extraction, sample: sample)
        asv = create(:asv, sample: sample, extraction: extraction,
                           primers: ['a'])

        subject(asv)
        expect(sample.reload.primers).to eq(['a'])
      end

      xit 'add multiple primers to sample from asv' do
        sample = create(:sample, primers: [])
        asv = create(:asv, sample: sample, primers: %w[a b])

        subject(asv)
        expect(sample.reload.primers).to match_array(%w[a b])
      end
    end

    context 'sample has primers' do
      xit 'appends one primer to sample from asv' do
        sample = create(:sample, primers: ['a'])
        extraction = create(:extraction, sample: sample)
        asv = create(:asv, sample: sample, extraction: extraction,
                           primers: ['b'])

        subject(asv)
        expect(sample.reload.primers).to match_array(%w[a b])
      end

      xit 'appends multiple primers to sample from asv' do
        sample = create(:sample, primers: ['a'])
        extraction = create(:extraction, sample: sample)
        asv = create(:asv, sample: sample, extraction: extraction,
                           primers: %w[b c])

        subject(asv)
        expect(sample.reload.primers).to match_array(%w[a b c])
      end

      xit 'ignores duplicate primers' do
        sample = create(:sample, primers: %w[a b])
        extraction = create(:extraction, sample: sample)
        asv = create(:asv, sample: sample, extraction: extraction,
                           primers: %w[a])

        subject(asv)
        expect(sample.reload.primers).to match_array(%w[a b])
      end

      xit 'handles a combination of new and duplicate primers' do
        sample = create(:sample, primers: %w[a c])
        extraction = create(:extraction, sample: sample)
        asv = create(:asv, sample: sample, extraction: extraction,
                           primers: %w[a b c d])

        subject(asv)
        expect(sample.reload.primers).to match_array(%w[a b c d])
      end
    end

    xit 'clean up primers' do
      sample = create(:sample, primers: [])
      extraction = create(:extraction, sample: sample)
      asv = create(:asv, sample: sample, extraction: extraction,
                         primers: %w[2s 3S x4S X5s as])

      subject(asv)
      expect(sample.reload.primers).to match_array(%w[2S 3S 4S 5S as])
    end
  end
end
