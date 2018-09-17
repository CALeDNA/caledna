import * as pp_utils from 'services/pp_utils';

describe('pp_utils', () => {
  describe('#capitalizeFirstLetter', () => {
    const subject = pp_utils.capitalizeFirstLetter;

    it('capitalizes first letter in a string', () => {
      const string = 'abc def'

      expect(subject(string)).toEqual('Abc def')
    })
  })

  describe('#formatLongTaxonString', () => {
    const subject = pp_utils.formatLongTaxonString;
    const taxaGroups = {
      animals: ['Animals', 'Animalia']
    }

    it('returns the divison, phylum and class for a taxon', () => {
      const taxon = {
        count: 1,
        division: "Animals",
        phylum: "Phylum",
        class: "Class",
        source: "ncbi"
      }
      const expected = 'Animals: Phylum, Class (eDNA)'

      expect(subject(taxon, taxaGroups)).toEqual(expected)
    })
  })

  describe('#formatChartData', () => {
    const subject = pp_utils.formatChartData;

    it('returns a hash with keys that chart library requires', () => {
      const taxon = {
        count: 1,
        division: "Animals",
        phylum: "Phylum",
        class: "Class",
        source: "ncbi"
      }
      const taxaGroups = {
        animals: ['Animals', 'Animalia']
      }
      const expected = {
        value: 1,
        division: "Animals",
        name: 'Animals: Phylum, Class (eDNA)',
        source: "ncbi",
        tooltip_name: "Animals: Phylum, Class (eDNA)",
      }

      expect(subject(taxon, taxaGroups)).toEqual(expected)
    })
  })

  describe('#sortData', () => {
    const subject = pp_utils.sortData;

    it('sorts data by value in asc order', () => {
      const data = [
        { value: 1, division: "Animals", name: 'name', source: "ncbi" },
        { value: 3, division: "Animals", name: 'name', source: "ncbi" },
        { value: 2, division: "Animals", name: 'name', source: "ncbi" },
      ]
      const expected = [
        { value: 1, division: "Animals", name: 'name', source: "ncbi" },
        { value: 2, division: "Animals", name: 'name', source: "ncbi" },
        { value: 3, division: "Animals", name: 'name', source: "ncbi" },
      ]

      expect(subject(data)).toEqual(expected)
    })
  })

  describe('#filterAndSortData', () => {
    const subject = pp_utils.filterAndSortData

    it('returns an sorted array taxons if filters do not exist', () =>{
      const data = [
        { value: 4, division: "Animals", name: 'a', source: "ncbi" },
        { value: 5, division: "Bacteria", name: 'b', source: "ncbi" },
        { value: 2, division: "Animalia", name: 'c', source: "gbif" },
        { value: 1, division: "Animalia", name: 'd', source: "gbif" },
        { value: 3, division: "Animals", name: 'e', source: "ncbi" },
      ]
      const taxaGroups = {
        animals: ['Animals', 'Animalia'],
        bacteria: ['Bacteria', 'Viruses', 'Archaea'],
      }
      const filters = { taxon_groups: [] }
      const options = {
        data,
        limit: 3,
        taxaGroups,
        filters,
      }

      const expected = [
        { value: 3, division: "Animals", name: 'e', source: "ncbi" },
        { value: 4, division: "Animals", name: 'a', source: "ncbi" },
        { value: 5, division: "Bacteria", name: 'b', source: "ncbi" },
      ]

      expect(subject(options)).toEqual(expected)
    })

    it('returns an sorted array of filtered taxons if filters exist', () =>{
      const data = [
        { value: 4, division: "Animals", name: 'a', source: "ncbi" },
        { value: 5, division: "Bacteria", name: 'b', source: "ncbi" },
        { value: 2, division: "Animalia", name: 'c', source: "gbif" },
        { value: 1, division: "Animalia", name: 'd', source: "gbif" },
        { value: 3, division: "Animals", name: 'e', source: "ncbi" },
      ]
      const taxaGroups = {
        animals: ['Animals', 'Animalia'],
        bacteria: ['Bacteria', 'Viruses', 'Archaea'],
      }
      const filters = { taxon_groups: ['animals'] }
      const options = {
        data,
        limit: 3,
        taxaGroups,
        filters,
      }

      const expected = [
        { value: 2, division: "Animalia", name: 'c', source: "gbif" },
        { value: 3, division: "Animals", name: 'e', source: "ncbi" },
        { value: 4, division: "Animals", name: 'a', source: "ncbi" },
      ]

      expect(subject(options)).toEqual(expected)
    })
  })
})



