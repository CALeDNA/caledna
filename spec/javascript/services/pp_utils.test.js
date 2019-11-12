import * as pp_utils from "services/pp_utils";

describe("pp_utils", () => {
  describe("#capitalizeFirstLetter", () => {
    const subject = pp_utils.capitalizeFirstLetter;

    it("capitalizes first letter in a string", () => {
      const string = "abc def";

      expect(subject(string)).toEqual("Abc def");
    });
  });

  describe("#formatLongTaxonString", () => {
    const subject = pp_utils.formatLongTaxonString;

    it("returns the kingdom, phylum and class if class follows phylum", () => {
      const taxon = {
        count: 1,
        division: "Division",
        kingdom: "Kingdom",
        phylum: "Phylum",
        class: "Class",
        order: "Order",
      };
      const expected = "Kingdom: Phylum, Class";

      expect(subject(taxon)).toEqual(expected);
    });

    it("returns the kingdom, phylum and order if order follows phylum", () => {
      const taxon = {
        count: 1,
        division: "Division",
        kingdom: "Kingdom",
        phylum: "Phylum",
        order: "Order",
        family: "Family",
      };
      const expected = "Kingdom: Phylum, Order";

      expect(subject(taxon)).toEqual(expected);
    });

    it("returns the kingdom, phylum and family if family follows phylum", () => {
      const taxon = {
        count: 1,
        division: "Division",
        kingdom: "Kingdom",
        phylum: "Phylum",
        family: "Family",
        genus: "Genus",
      };
      const expected = "Kingdom: Phylum, Family";

      expect(subject(taxon)).toEqual(expected);
    });

    it("returns the kingdom, phylum and genus if genus follows phylum", () => {
      const taxon = {
        count: 1,
        division: "Division",
        kingdom: "Kingdom",
        phylum: "Phylum",
        genus: "Genus",
        species: "Species",
      };
      const expected = "Kingdom: Phylum, Genus";

      expect(subject(taxon)).toEqual(expected);
    });

    it("returns the kingdom, phylum and species if species follows phylum", () => {
      const taxon = {
        count: 1,
        division: "Division",
        kingdom: "Kingdom",
        phylum: "Phylum",
        species: "Species",
      };
      const expected = "Kingdom: Phylum, Species";

      expect(subject(taxon)).toEqual(expected);
    });
  });

  describe("#formatChartData", () => {
    const subject = pp_utils.formatChartData;

    it("returns a hash with keys that chart library requires", () => {
      const taxon = {
        count: 1,
        division: "Division",
        kingdom: "Kingdom",
        phylum: "Phylum",
        class: "Class",
        source: "ncbi",
      };

      const expected = {
        value: 1,
        division: "Division",
        name: "Kingdom: Phylum, Class",
        source: "ncbi",
        tooltip_name: "Kingdom: Phylum, Class",
      };

      expect(subject(taxon)).toEqual(expected);
    });
  });

  describe("#sortData", () => {
    const subject = pp_utils.sortData;

    it("sorts data by value in asc order", () => {
      const data = [
        { value: 1, division: "Division", name: "name", source: "ncbi" },
        { value: 3, division: "Division", name: "name", source: "ncbi" },
        { value: 2, division: "Division", name: "name", source: "ncbi" },
      ];
      const expected = [
        { value: 1, division: "Division", name: "name", source: "ncbi" },
        { value: 2, division: "Division", name: "name", source: "ncbi" },
        { value: 3, division: "Division", name: "name", source: "ncbi" },
      ];

      expect(subject(data)).toEqual(expected);
    });
  });
});
