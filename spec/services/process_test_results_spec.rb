# frozen_string_literal: true

require 'rails_helper'

describe ProcessTestResults do
  let(:dummy_class) { Class.new { extend ProcessTestResults } }

  describe '#get_taxon_rank' do
    def subject(string)
      dummy_class.get_taxon_rank(string)
    end

    it 'returns species if it exists' do
      string = 'Phylum;Class;Order;Family;Genus;Species'
      expect(subject(string)).to eq('species')
    end

    it 'returns genus if it exists' do
      string = 'Phylum;Class;Order;Family;Genus;'
      expect(subject(string)).to eq('genus')
    end

    it 'returns family if it exists' do
      string = 'Phylum;Class;Order;Family;;'
      expect(subject(string)).to eq('family')
    end

    it 'returns order if it exists' do
      string = 'Phylum;Class;Order;;;'
      expect(subject(string)).to eq('order')
    end

    it 'returns class if it exists' do
      string = 'Phylum;Class;;;;'
      expect(subject(string)).to eq('class')
    end

    it 'returns phylum if it exists' do
      string = 'Phylum;;;;;'
      expect(subject(string)).to eq('phylum')
    end

    it 'ignores "uncultured"' do
      string = 'Phylum;Class;Order;Family;Genus;uncultured thing'
      expect(subject(string)).to eq('genus')
    end

    it 'ignores "NA"' do
      string = 'Phylum;Class;Order;Family;NA;NA'
      expect(subject(string)).to eq('family')
    end

    it 'retuns nil when entire string is "NA"' do
      string = 'NA'
      expect(subject(string)).to eq(nil)
    end

    it 'retuns nil when entire string is ";;;;;"' do
      string = ';;;;;'
      expect(subject(string)).to eq(nil)
    end
  end

  describe '#get_hierarchy' do
    def subject(string)
      dummy_class.get_hierarchy(string)
    end

    it 'returns a hash of taxonomy names' do
      create(:taxon, kingdom: 'Kingdom', phylum: 'Phylum', taxonRank: 'phylum')
      string = 'Phylum;Class;Order;Family;Genus;Species'

      expect(subject(string)[:kingdom]).to eq('Kingdom')
      expect(subject(string)[:phylum]).to eq('Phylum')
      expect(subject(string)[:class]).to eq('Class')
      expect(subject(string)[:order]).to eq('Order')
      expect(subject(string)[:family]).to eq('Family')
      expect(subject(string)[:genus]).to eq('Genus')
      expect(subject(string)[:species]).to eq('Species')
    end

    it 'returns nil for missing taxa' do
      create(:taxon, kingdom: 'Kingdom', phylum: 'Phylum', taxonRank: 'phylum')
      string = 'Phylum;Class;;Family;Genus;'

      expect(subject(string)[:kingdom]).to eq('Kingdom')
      expect(subject(string)[:phylum]).to eq('Phylum')
      expect(subject(string)[:class]).to eq('Class')
      expect(subject(string)[:order]).to eq(nil)
      expect(subject(string)[:family]).to eq('Family')
      expect(subject(string)[:genus]).to eq('Genus')
      expect(subject(string)[:species]).to eq(nil)
    end

    it 'returns nil for "NA" taxa' do
      create(:taxon, kingdom: 'Kingdom', phylum: 'Phylum', taxonRank: 'phylum')
      string = 'Phylum;Class;NA;Family;Genus;NA'

      expect(subject(string)[:kingdom]).to eq('Kingdom')
      expect(subject(string)[:phylum]).to eq('Phylum')
      expect(subject(string)[:class]).to eq('Class')
      expect(subject(string)[:order]).to eq(nil)
      expect(subject(string)[:family]).to eq('Family')
      expect(subject(string)[:genus]).to eq('Genus')
      expect(subject(string)[:species]).to eq(nil)
    end

    it 'retuns empty hash when entire string is "NA"' do
      string = 'NA'
      expect(subject(string)).to eq({})
    end

    it 'retuns empty hash when entire string is ";;;;;"' do
      string = ';;;;;'
      expect(subject(string)).to eq({})
    end
  end

  describe '#find_accepted_taxon' do
    def subject(hierarchy, rank)
      dummy_class.find_accepted_taxon(hierarchy, rank)
    end

    it 'returns matching Taxon for a taxon string' do
      rank = 'phylum'
      taxon = create(
        :taxon,
        kingdom: 'Kingdom',
        phylum: 'Phylum',
        taxonRank: rank,
        canonicalName: 'Phylum'
      )
      string = 'Phylum;;;;;'
      hierarchy = dummy_class.get_hierarchy(string)

      expect(subject(hierarchy, rank)).to eq(taxon)
    end

    it 'returns accepted Taxon for a taxon string' do
      rank = 'phylum'
      taxon = create(
        :taxon,
        kingdom: 'Kingdom',
        phylum: 'Phylum',
        taxonRank: rank,
        canonicalName: 'Phylum'
      )
      string = 'Phylum;;;;;'
      hierarchy = dummy_class.get_hierarchy(string)

      expect(subject(hierarchy, rank)).to eq(taxon)
    end
  end

  describe '#get_complete_taxon_string' do
    def subject(string)
      dummy_class.get_complete_taxon_string(string)
    end

    it 'adds kingdom to taxomony if phylum has a kingdom' do
      create(:taxon, kingdom: 'Kingdom', phylum: 'Phylum', taxonRank: 'phylum')
      string = 'Phylum;Class;Order;Family;Genus;Species'
      expected = 'Kingdom;Phylum;Class;Order;Family;Genus;Species'

      expect(subject(string)).to eq(expected)
    end

    it 'adds "NA" to taxomony if phylum does have a kingdom' do
      string = 'Phylum;Class;Order;Family;Genus;Species'
      expected = 'NA;Phylum;Class;Order;Family;Genus;Species'

      expect(subject(string)).to eq(expected)
    end
  end

  describe '#find_sample_from_barcode' do
    let(:barcode) { 'K0001-LA-S1' }
    let(:project) { create(:field_data_project, name: 'unknown') }

    def subject
      dummy_class.find_sample_from_barcode(barcode)
    end

    context 'there are no samples for a given bar code' do
      it 'creates a new sample' do
        stub_const('FieldDataProject::DEFAULT_PROJECT', project)

        expect { subject }.to change { Sample.count }.by(1)
      end

      it 'returns the created sample' do
        stub_const('FieldDataProject::DEFAULT_PROJECT', project)
        result = subject

        expect(result.barcode).to eq(barcode)
        expect(result.field_data_project).to eq(project)
        expect(result.status_cd).to eq('missing_coordinates')
      end
    end

    context 'there is one valid sample for a given barcode' do
      it 'returns the matching sample' do
        sample = create(:sample, status_cd: :approved, barcode: barcode)
        result = subject

        expect(result).to eq(sample)
      end

      it 'updates status to results_completed' do
        create(:sample, status_cd: :approved, barcode: barcode)
        result = subject

        expect(result.status_cd).to eq('results_completed')
      end

      it 'does not update status when status is missing_coordinates' do
        create(:sample, status_cd: :missing_coordinates, barcode: barcode)
        result = subject

        expect(result.status_cd).to eq('missing_coordinates')
      end
    end

    context 'there is one valid and one invalid sample for a given barcode' do
      it 'returns the matching  valid sample' do
        sample = create(:sample, status_cd: :approved, barcode: barcode)
        create(:sample, status_cd: :rejected, barcode: barcode)
        result = subject

        expect(result).to eq(sample)
      end

      it 'updates status to results_completed' do
        create(:sample, status_cd: :approved, barcode: barcode)
        create(:sample, status_cd: :rejected, barcode: barcode)
        result = subject

        expect(result.status_cd).to eq('results_completed')
      end

      it 'does not update status when status is missing_coordinates' do
        create(:sample, status_cd: :missing_coordinates, barcode: barcode)
        create(:sample, status_cd: :rejected, barcode: barcode)
        result = subject

        expect(result.status_cd).to eq('missing_coordinates')
      end
    end

    context 'there are multiple valid samples for a given barcode' do
      it 'raises an error' do
        create(:sample, status_cd: :approved, barcode: barcode)
        create(:sample, status_cd: :results_completed, barcode: barcode)

        message = /multiple samples with barcode/
        expect { subject }.to raise_error(ImportError, message)
      end
    end

    context 'all samples are rejected for a given barcode' do
      it 'raises an error when there is one sample' do
        create(:sample, status_cd: :rejected, barcode: barcode)

        message = /was previously rejected/
        expect { subject }.to raise_error(ImportError, message)
      end

      it 'raises an error when there are multiple samples' do
        create(:sample, status_cd: :rejected, barcode: barcode)
        create(:sample, status_cd: :rejected, barcode: barcode)

        message = /was previously rejected/
        expect { subject }.to raise_error(ImportError, message)
      end
    end

    context 'all samples are duplicate_barcode for a given bar code' do
      it 'raises an error when there is one sample' do
        create(:sample, status_cd: :duplicate_barcode, barcode: barcode)

        message = /was previously rejected/
        expect { subject }.to raise_error(ImportError, message)
      end

      it 'raises an error when there are multiple samples' do
        create(:sample, status_cd: :duplicate_barcode, barcode: barcode)
        create(:sample, status_cd: :duplicate_barcode, barcode: barcode)

        message = /was previously rejected/
        expect { subject }.to raise_error(ImportError, message)
      end
    end
  end
end
