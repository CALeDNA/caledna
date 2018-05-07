# frozen_string_literal: true

require 'rails_helper'

describe ProcessTestResults do
  let(:dummy_class) { Class.new { extend ProcessTestResults } }

  describe '#find_taxon_from_string' do
    def subject(string)
      dummy_class.find_taxon_from_string(string)
    end

    it 'returns taxon data for Durinskia' do
      lineage = [
        [131_567, 'cellular organisms', 'no rank'],
        [2_759, 'Eukaryota', 'superkingdom'],
        [33_630, 'Alveolata', 'no rank'],
        [2_864, 'Dinophyceae', 'class'],
        [2_910, 'Peridiniales', 'order'],
        [2_137_591, 'Kryptoperidiniaceae', 'family'],
        [400_754, 'Durinskia', 'genus']
      ]
      taxon = create(:ncbi_node, lineage: lineage, canonical_name: 'Durinskia',
                                 rank: 'genus')
      create(:ncbi_name, name: 'Durinskia', taxon_id: taxon.id)

      string = ';Dinophyceae;Peridiniales;Kryptoperidiniaceae;Durinskia;'
      # string = ';Dinophyceae;Peridiniales;Peridiniaceae;Durinskia;'

      expect(subject(string)[:complete_taxonomy])
        .to eq("Eukaryota;;#{string}")
      expect(subject(string)[:taxon_id]).to eq(taxon.id)
    end

    it 'returns taxon data for Astigmata' do
      lineage = [
        [131567, 'cellular organisms', 'no rank'],
        [2759, 'Eukaryota', 'superkingdom'],
        [33154, 'Opisthokonta', 'no rank'],
        [33208, 'Metazoa', 'kingdom'],
        [6072, 'Eumetazoa', 'no rank'],
        [33213, 'Bilateria', 'no rank'],
        [33317, 'Protostomia', 'no rank'],
        [1206794, 'Ecdysozoa', 'no rank'],
        [88770, 'Panarthropoda', 'no rank'],
        [6656, 'Arthropoda', 'phylum'],
        [6843, 'Chelicerata', 'subphylum'],
        [6854, 'Arachnida', 'class'],
        [6933, 'Acari', 'subclass'],
        [6946, 'Acariformes', 'superorder'],
        [83137, 'Sarcoptiformes', 'order'],
        [6951, 'Astigmata', 'suborder']
      ]
      taxon = create(:ncbi_node, lineage: lineage, canonical_name: 'Sarcoptiformes',
                                 rank: 'order')
      create(:ncbi_name, name: 'Sarcoptiformes', taxon_id: taxon.id)

      string = 'Arthropoda;Arachnida;Sarcoptiformes;NA;;'
      # string = 'Arthropoda;Arachnida;Astigmata;NA;;'

      expect(subject(string)[:complete_taxonomy])
        .to eq("Eukaryota;Metazoa;#{string}")
      expect(subject(string)[:taxon_id]).to eq(taxon.id)
    end

    it 'returns a hash of taxon info when all ranks are present' do
      string = 'Phylum;Class;Order;Family;Genus;Species'
      lineage = [
        [1, 'Superkingdom', 'superkingdom'],
        [2, 'Kingdom', 'kingdom'],
        [3, 'Phylum', 'phylum'],
        [4, 'Class', 'class'],
        [5, 'Order', 'order'],
        [6, 'Family', 'family'],
        [7, 'Genus', 'genus'],
        [8, 'Species', 'species']
      ]
      taxon = create(:ncbi_node, lineage: lineage, canonical_name: 'Species',
                                 rank: 'species')
      create(:ncbi_name, name: 'Species', taxon_id: taxon.id)

      expect(subject(string)[:original_taxonomy]).to eq(string)
      expect(subject(string)[:complete_taxonomy])
        .to eq("Superkingdom;Kingdom;#{string}")
      expect(subject(string)[:taxon_id]).to eq(taxon.id)
      expect(subject(string)[:rank]).to eq('species')
      expect(subject(string)[:original_hierarchy]).to include(
        superkingdom: 'Superkingdom', kingdom: 'Kingdom', class: 'Class',
        order: 'Order', family: 'Family', genus: 'Genus', species: 'Species'
      )
    end

    it 'returns a hash of taxon info when there are missing ranks' do
      string = ';Class;Order;;Genus;'
      lineage = [
        [1, 'Superkingdom', 'superkingdom'],
        [4, 'Class', 'class'],
        [5, 'Order', 'order'],
        [7, 'Genus', 'genus']
      ]
      taxon = create(:ncbi_node, lineage: lineage, canonical_name: 'Genus',
                                 rank: 'genus')
      create(:ncbi_name, name: 'Genus', taxon_id: taxon.id)

      expect(subject(string)[:original_taxonomy]).to eq(';Class;Order;;Genus;')
      expect(subject(string)[:complete_taxonomy])
        .to eq("Superkingdom;;#{string}")
      expect(subject(string)[:taxon_id]).to eq(taxon.id)
      expect(subject(string)[:rank]).to eq('genus')
      expect(subject(string)[:original_hierarchy]).to include(
        superkingdom: 'Superkingdom', class: 'Class',
        order: 'Order', genus: 'Genus'
      )
    end

    it 'returns a hash of taxon info when there are NA ranks' do
      string = 'NA;Class;Order;NA;Genus;'
      lineage = [
        [1, 'Superkingdom', 'superkingdom'],
        [4, 'Class', 'class'],
        [5, 'Order', 'order'],
        [7, 'Genus', 'genus']
      ]
      taxon = create(:ncbi_node, lineage: lineage, canonical_name: 'Genus',
                                 rank: 'genus')
      create(:ncbi_name, name: 'Genus', taxon_id: taxon.id)

      expect(subject(string)[:original_taxonomy])
        .to eq('NA;Class;Order;NA;Genus;')
      expect(subject(string)[:complete_taxonomy])
        .to eq("Superkingdom;;#{string}")
      expect(subject(string)[:taxon_id]).to eq(taxon.id)
      expect(subject(string)[:rank]).to eq('genus')
      expect(subject(string)[:original_hierarchy]).to include(
        superkingdom: 'Superkingdom', class: 'Class',
        order: 'Order', genus: 'Genus'
      )
    end
  end

  describe '#get_taxon_rank' do
    def subject(string)
      dummy_class.get_taxon_rank(string)
    end

    it 'returns species if it exists' do
      string = 'Phylum;Class;Order;Family;Genus;Species'
      expect(subject(string)).to eq('species')
    end

    it 'returns species if only species exists' do
      string = ';;;;;Species'
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

    it 'ignores "NA"' do
      string = 'Phylum;Class;Order;Family;NA;NA'
      expect(subject(string)).to eq('family')
    end

    it 'retuns "unknown" when entire string is "NA"' do
      string = 'NA'
      expect(subject(string)).to eq('unknown')
    end

    it 'retuns "unknown" when entire string is ";;;;;"' do
      string = ';;;;;'
      expect(subject(string)).to eq('unknown')
    end
  end

  describe '#get_hierarchy' do
    def subject(string, rank)
      dummy_class.get_hierarchy(string, rank)
    end

    it 'returns a hash of taxonomy names' do
      taxon = create(
        :ncbi_node,
        canonical_name: 'Species',
        rank: 'species',
        lineage: [
          [1, 'Superkingdom', 'superkingdom'],
          [2, 'Kingdom', 'kingdom'],
          [3, 'Phylum', 'phylum'],
          [4, 'Class', 'class'],
          [5, 'Order', 'order'],
          [6, 'Family', 'family'],
          [7, 'Genus', 'genus'],
          [8, 'Species', 'species']
        ]
      )
      create(:ncbi_name, name: 'Species', taxon_id: taxon.id)

      string = 'Phylum;Class;Order;Family;Genus;Species'
      rank = 'species'
      expected = {
        superkingdom: 'Superkingdom',
        kingdom: 'Kingdom',
        phylum: 'Phylum',
        class: 'Class',
        order: 'Order',
        family: 'Family',
        genus: 'Genus',
        species: 'Species'
      }

      expect(subject(string, rank)).to eq(expected)
    end

    it 'returns hash that does not contain missing taxa' do
      taxon = create(
        :ncbi_node,
        canonical_name: 'Genus',
        rank: 'genus',
        lineage: [
          [1, 'Superkingdom', 'superkingdom'],
          [2, 'Kingdom', 'kingdom'],
          [3, 'Phylum', 'phylum'],
          [4, 'Class', 'class'],
          [6, 'Family', 'family'],
          [7, 'Genus', 'genus']
        ]
      )
      create(:ncbi_name, name: 'Genus', taxon_id: taxon.id)

      string = 'Phylum;Class;;Family;Genus;'
      rank = 'genus'
      expected = {
        superkingdom: 'Superkingdom',
        kingdom: 'Kingdom',
        phylum: 'Phylum',
        class: 'Class',
        family: 'Family',
        genus: 'Genus'
      }

      expect(subject(string, rank)).to eq(expected)
    end

    it 'returns hash that does not contain "NA" taxa' do
      taxon = create(
        :ncbi_node,
        canonical_name: 'Genus',
        rank: 'genus',
        lineage: [
          [1, 'Superkingdom', 'superkingdom'],
          [2, 'Kingdom', 'kingdom'],
          [3, 'Phylum', 'phylum'],
          [4, 'Class', 'class'],
          [6, 'Family', 'family'],
          [7, 'Genus', 'genus']
        ]
      )
      create(:ncbi_name, name: 'Genus', taxon_id: taxon.id)

      string = 'Phylum;Class;NA;Family;Genus;NA'
      rank = 'genus'
      expected = {
        superkingdom: 'Superkingdom',
        kingdom: 'Kingdom',
        phylum: 'Phylum',
        class: 'Class',
        family: 'Family',
        genus: 'Genus'
      }

      expect(subject(string, rank)).to eq(expected)
    end

    it 'retuns empty hash when entire string is "NA"' do
      string = 'NA'
      rank = nil
      expect(subject(string, rank)).to eq({})
    end

    it 'retuns empty hash when entire string is ";;;;;"' do
      string = ';;;;;'
      rank = nil
      expect(subject(string, rank)).to eq({})
    end
  end

  describe '#find_exact_taxon' do
    def subject(hierarchy, rank)
      dummy_class.find_exact_taxon(hierarchy, rank)
    end

    def hierarchy
      {
        superkingdom: 'Superkingdom', kingdom: 'Kingdom',
        phylum: 'Phylum', class: 'Class',  order: 'Order', family: 'Family',
        genus: 'Genus', species: 'Species'
      }
    end

    context 'when taxon name has quotes' do
      it 'returns matching NcbiNode' do
        hierarchy = {
          superkingdom: 'Superkingdom', kingdom: nil,
          phylum: "'Phylum'", class: nil, order: nil, family: nil,
          genus: nil, species: nil
        }
        rank = 'phylum'
        taxon = create(:ncbi_node, rank: 'phylum', canonical_name: "'Phylum'")
        create(:ncbi_name, taxon_id: taxon.id, name: "'Phylum'")

        expect(subject(hierarchy, rank)).to eq(taxon)
      end

    end

    context 'when rank has unique taxon names' do
      def create_taxons(canonical_name, rank)
        t = create(:ncbi_node, rank: rank, canonical_name: 'random1')
        create(:ncbi_name, name: 'random1', taxon_id: t.id)

        taxon = create(:ncbi_node, rank: rank, canonical_name: canonical_name)
        create(:ncbi_name, name: canonical_name, taxon_id: taxon.id)

        t = create(:ncbi_node, rank: rank, canonical_name: 'random2')
        create(:ncbi_name, name: 'random2', taxon_id: t.id)

        taxon
      end

      it 'returns matching NcbiNode when rank is phylum' do
        hierarchy = {
          superkingdom: 'Superkingdom', kingdom: nil,
          phylum: 'Phylum', class: nil, order: nil, family: nil,
          genus: nil, species: nil
        }
        rank = 'phylum'
        taxon = create_taxons('Phylum', rank)

        expect(subject(hierarchy, rank)).to eq(taxon)
      end

      it 'returns matching NcbiNode when rank is class' do
        hierarchy = {
          superkingdom: 'Superkingdom', kingdom: nil,
          phylum: nil, class: 'Class',  order: nil, family: nil,
          genus: nil, species: nil
        }
        rank = 'class'
        taxon = create_taxons('Class', rank)

        expect(subject(hierarchy, rank)).to eq(taxon)
      end

      it 'returns matching NcbiNode when rank is order' do
        hierarchy = {
          superkingdom: 'Superkingdom', kingdom: nil,
          phylum: nil, class: nil, order: 'Order', family: nil,
          genus: nil, species: nil
        }
        rank = 'order'
        taxon = create_taxons('Order', rank)

        expect(subject(hierarchy, rank)).to eq(taxon)
      end

      it 'returns matching NcbiNode when rank is species' do
        hierarchy = {
          superkingdom: 'Superkingdom', kingdom: nil,
          phylum: nil, class: nil, order: nil, family: nil,
          genus: nil, species: 'Species'
        }
        rank = 'species'
        taxon = create_taxons('Species', rank)

        expect(subject(hierarchy, rank)).to eq(taxon)
      end
    end

    context 'when rank is family' do
      def create_taxon(rank, lineage)
        taxon = create(:ncbi_node, rank: rank, canonical_name: 'Family',
                                   lineage: lineage)
        create(:ncbi_name, name: 'Family', taxon_id: taxon.id)
        taxon
      end

      it 'returns matching NcbiNode when phylum exists' do
        hierarchy = {
          superkingdom: nil, kingdom: nil,
          phylum: 'Phylum', class: nil, order: nil, family: 'Family',
          genus: nil, species: nil
        }
        rank = 'family'

        family_lineage = [6, 'Family', 'family']
        create_taxon(rank, [[3, 'bad', 'phylum'], family_lineage])
        taxon = create_taxon(rank, [[3, 'Phylum', 'phylum'], family_lineage])
        create_taxon(rank, [family_lineage])

        expect(subject(hierarchy, rank)).to eq(taxon)
      end

      it 'returns matching NcbiNode when phylum does not exist' do
        hierarchy = {
          superkingdom: nil, kingdom: nil,
          phylum: nil, class: nil, order: nil, family: 'Family',
          genus: nil, species: nil
        }
        rank = 'family'

        family_lineage = [6, 'Family', 'family']
        create_taxon(rank, [[1, 'bad', 'phylum'], family_lineage])
        create_taxon(rank, [[2, 'Phylum', 'phylum'], family_lineage])
        taxon = create_taxon(rank, [family_lineage])

        expect(subject(hierarchy, rank)).to eq(taxon)
      end
    end

    context 'when rank is genus' do
      def create_taxon(rank, lineage)
        taxon = create(:ncbi_node, rank: rank, canonical_name: 'Genus',
                                   lineage: lineage)
        create(:ncbi_name, name: 'Genus', taxon_id: taxon.id)
        taxon
      end

      it 'returns matching NcbiNode when all main ranks are present' do
        hierarchy = {
          superkingdom: 'Superkingdom', kingdom: 'Kingdom',
          phylum: 'Phylum', class: 'Class',  order: 'Order', family: 'Family',
          genus: 'Genus', species: nil
        }
        rank = 'genus'

        lineage = [
          [1, 'Superkingdom', 'superkingdom'],
          [2, 'Kingdom', 'kingdom'],
          [3, 'Phylum', 'phylum'],
          [4, 'Class', 'class'],
          [5, 'random', 'order'],
          [6, 'Family', 'family'],
          [7, 'Genus', 'genus']
        ]
        create_taxon(rank, lineage)
        lineage = [
          [1, 'Superkingdom', 'superkingdom'],
          [2, 'Kingdom', 'kingdom'],
          [3, 'Phylum', 'phylum'],
          [4, 'Class', 'class'],
          [5, 'Order', 'order'],
          [6, 'Family', 'family'],
          [7, 'Genus', 'genus']
        ]
        taxon = create_taxon(rank, lineage)
        create_taxon(rank, [])

        expect(subject(hierarchy, rank)).to eq(taxon)
      end

      it 'returns matching NcbiNode when kingdom is missing' do
        hierarchy = {
          superkingdom: nil, kingdom: nil,
          phylum: 'Phylum', class: 'Class', order: 'Order', family: 'Family',
          genus: 'Genus', species: nil
        }
        rank = 'genus'

        lineage = [
          [3, 'Phylum', 'phylum'],
          [4, 'Class', 'class'],
          [5, 'random', 'order'],
          [6, 'Family', 'family'],
          [7, 'Genus', 'genus']
        ]
        create_taxon(rank, lineage)
        lineage = [
          [3, 'Phylum', 'phylum'],
          [4, 'Class', 'class'],
          [5, 'Order', 'order'],
          [6, 'Family', 'family'],
          [7, 'Genus', 'genus']
        ]
        taxon = create_taxon(rank, lineage)
        create_taxon(rank, [])

        expect(subject(hierarchy, rank)).to eq(taxon)
      end

      it 'returns matching NcbiNode when phylum is missing' do
        hierarchy = {
          superkingdom: 'Superkingdom', kingdom: 'Kingdom',
          phylum: nil, class: 'Class',  order: 'Order', family: 'Family',
          genus: 'Genus', species: nil
        }
        rank = 'genus'

        lineage = [
          [1, 'Superkingdom', 'superkingdom'],
          [2, 'Kingdom', 'kingdom'],
          [4, 'Class', 'class'],
          [5, 'random', 'order'],
          [6, 'Family', 'family'],
          [7, 'Genus', 'genus']
        ]
        create_taxon(rank, lineage)
        lineage = [
          [1, 'Superkingdom', 'superkingdom'],
          [2, 'Kingdom', 'kingdom'],
          [4, 'Class', 'class'],
          [5, 'Order', 'order'],
          [6, 'Family', 'family'],
          [7, 'Genus', 'genus']
        ]
        taxon = create_taxon(rank, lineage)
        create_taxon(rank, [])

        expect(subject(hierarchy, rank)).to eq(taxon)
      end

      it 'returns matching NcbiNode when class is missing' do
        hierarchy = {
          superkingdom: 'Superkingdom', kingdom: 'Kingdom',
          phylum: 'Phylum', class: nil, order: 'Order', family: 'Family',
          genus: 'Genus', species: nil
        }
        rank = 'genus'

        lineage = [
          [1, 'Superkingdom', 'superkingdom'],
          [2, 'Kingdom', 'kingdom'],
          [3, 'Phylum', 'phylum'],
          [5, 'random', 'order'],
          [6, 'Family', 'family'],
          [7, 'Genus', 'genus']
        ]
        create_taxon(rank, lineage)
        lineage = [
          [1, 'Superkingdom', 'superkingdom'],
          [2, 'Kingdom', 'kingdom'],
          [3, 'Phylum', 'phylum'],
          [5, 'Order', 'order'],
          [6, 'Family', 'family'],
          [7, 'Genus', 'genus']
        ]
        taxon = create_taxon(rank, lineage)
        create_taxon(rank, [])

        expect(subject(hierarchy, rank)).to eq(taxon)
      end

      it 'returns matching NcbiNode when order is missing' do
        hierarchy = {
          superkingdom: 'Superkingdom', kingdom: 'Kingdom',
          phylum: 'Phylum', class: 'Class',  order: nil, family: 'Family',
          genus: 'Genus', species: nil
        }
        rank = 'genus'

        lineage = [
          [1, 'Superkingdom', 'superkingdom'],
          [2, 'Kingdom', 'kingdom'],
          [3, 'Phylum', 'phylum'],
          [4, 'Class', 'class'],
          [6, 'random', 'family'],
          [7, 'Genus', 'genus']
        ]
        create_taxon(rank, lineage)
        lineage = [
          [1, 'Superkingdom', 'superkingdom'],
          [2, 'Kingdom', 'kingdom'],
          [3, 'Phylum', 'phylum'],
          [4, 'Class', 'class'],
          [6, 'Family', 'family'],
          [7, 'Genus', 'genus']
        ]
        taxon = create_taxon(rank, lineage)
        create_taxon(rank, [])

        expect(subject(hierarchy, rank)).to eq(taxon)
      end

      it 'returns matching NcbiNode when family is missing' do
        hierarchy = {
          superkingdom: 'Superkingdom', kingdom: 'Kingdom',
          phylum: 'Phylum', class: 'Class',  order: 'Order', family: nil,
          genus: 'Genus', species: nil
        }
        rank = 'genus'

        lineage = [
          [1, 'Superkingdom', 'superkingdom'],
          [2, 'Kingdom', 'kingdom'],
          [3, 'Phylum', 'phylum'],
          [4, 'Class', 'class'],
          [5, 'random', 'order'],
          [7, 'Genus', 'genus']
        ]
        create_taxon(rank, lineage)
        lineage = [
          [1, 'Superkingdom', 'superkingdom'],
          [2, 'Kingdom', 'kingdom'],
          [3, 'Phylum', 'phylum'],
          [4, 'Class', 'class'],
          [5, 'Order', 'order'],
          [7, 'Genus', 'genus']
        ]
        taxon = create_taxon(rank, lineage)
        create_taxon(rank, [])

        expect(subject(hierarchy, rank)).to eq(taxon)
      end
    end
  end

  describe '#get_complete_taxon_string' do
    def subject(string)
      dummy_class.get_complete_taxon_string(string)
    end

    it 'adds kingdoms to taxomony string if matching NcbiNode has kingdoms' do
      lineage = [
        [1, 'Superkingdom', 'superkingdom'],
        [2, 'Kingdom', 'kingdom'],
        [3, 'Phylum', 'phylum'],
        [5, 'Order', 'order']
      ]
      taxon = create(:ncbi_node, rank: 'order', canonical_name: 'Order',
                                 lineage: lineage)
      create(:ncbi_name, name: 'Order', taxon_id: taxon.id)

      string = 'Phylum;;Order;;;'
      expected = 'Superkingdom;Kingdom;Phylum;;Order;;;'

      expect(subject(string)).to eq(expected)
    end

    it 'adds kingdom to taxomony string if matching NcbiNode has kingdom' do
      lineage = [
        [2, 'Kingdom', 'kingdom'],
        [4, 'Class', 'class']
      ]
      taxon = create(:ncbi_node, rank: 'class', canonical_name: 'Class',
                                 lineage: lineage)
      create(:ncbi_name, name: 'Class', taxon_id: taxon.id)
      string = ';Class;;;;'
      expected = ';Kingdom;;Class;;;;'

      expect(subject(string)).to eq(expected)
    end

    it 'adds superkingdom to string if matching NcbiNode has superkingdom' do
      lineage = [
        [1, 'Superkingdom', 'superkingdom'],
        [4, 'Class', 'class']
      ]
      taxon = create(:ncbi_node, rank: 'class', canonical_name: 'Class',
                                 lineage: lineage)
      create(:ncbi_name, name: 'Class', taxon_id: taxon.id)
      string = ';Class;;;;'
      expected = 'Superkingdom;;;Class;;;;'

      expect(subject(string)).to eq(expected)
    end

    it 'adds ";;" to string if matching NcbiNode does not have "kingdoms"' do
      lineage = [
        [3, 'Phylum', 'phylum'],
        [4, 'Class', 'class']
      ]
      taxon = create(:ncbi_node, rank: 'class', canonical_name: 'Class',
                                 lineage: lineage)
      create(:ncbi_name, name: 'Class', taxon_id: taxon.id)
      string = 'Phylum;Class;;;;'
      expected = ';;Phylum;Class;;;;'

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
        expect { subject }.to raise_error(TaxaError, message)
      end
    end

    context 'all samples are rejected for a given barcode' do
      it 'raises an error when there is one sample' do
        create(:sample, status_cd: :rejected, barcode: barcode)

        message = /was previously rejected/
        expect { subject }.to raise_error(TaxaError, message)
      end

      it 'raises an error when there are multiple samples' do
        create(:sample, status_cd: :rejected, barcode: barcode)
        create(:sample, status_cd: :rejected, barcode: barcode)

        message = /was previously rejected/
        expect { subject }.to raise_error(TaxaError, message)
      end
    end

    context 'all samples are duplicate_barcode for a given bar code' do
      it 'raises an error when there is one sample' do
        create(:sample, status_cd: :duplicate_barcode, barcode: barcode)

        message = /was previously rejected/
        expect { subject }.to raise_error(TaxaError, message)
      end

      it 'raises an error when there are multiple samples' do
        create(:sample, status_cd: :duplicate_barcode, barcode: barcode)
        create(:sample, status_cd: :duplicate_barcode, barcode: barcode)

        message = /was previously rejected/
        expect { subject }.to raise_error(TaxaError, message)
      end
    end
  end

  describe '#get_kingdom_superkingdom' do
    def subject(taxon)
      dummy_class.get_kingdom_superkingdom(taxon)
    end

    it 'returns a hash with kingdoms' do
      lineages = [
        [1, 'Kingdom', 'kingdom'], [2, 'Superkingdom', 'superkingdom']
      ]
      taxon = create(:ncbi_node, lineage: lineages)

      expect(subject(taxon))
        .to eq(kingdom: 'Kingdom', superkingdom: 'Superkingdom')
    end

    it 'returns hash with nil kingdoms when no kingdoms lineage' do
      taxon = create(:ncbi_node, lineage: [])

      expect(subject(taxon)).to eq(kingdom: nil, superkingdom: nil)
    end
  end
end
