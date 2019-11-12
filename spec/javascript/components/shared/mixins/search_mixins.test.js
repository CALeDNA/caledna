import { searchMixins } from "components/shared/mixins/search_mixins";

describe("search_mixins", () => {
  describe("#flattenCurrentFilters", () => {
    const subject = searchMixins.methods.flattenCurrentFilters;

    it("merges values from multiple arrays into one array", () => {
      const filters = { a: ["a1", "a2"], b: ["b1", "b2"] };

      expect(subject(filters)).toEqual(["a1", "a2", "b1", "b2"]);
    });

    it("merges multiple strings into one array", () => {
      const filters = { a: "a1", b: "b1" };

      expect(subject(filters)).toEqual(["a1", "b1"]);
    });

    it("ignores 'all' values", () => {
      const string = { a: ["all"], b: "all" };

      expect(subject(string)).toEqual([]);
    });

    it("merges a combination of arrays and strings into one array", () => {
      const filters = {
        a: ["a1", "a2"],
        b: "b1",
        c: ["c1"],
        d: "all",
        e: ["all"],
      };

      expect(subject(filters)).toEqual(["a1", "a2", "b1", "c1"]);
    });
  });

  describe("#filterSamples", () => {
    const subject = searchMixins.methods.filterSamples;

    const sample1 = {
      id: 1,
      status: "status1",
      primers: ["primer1"],
      substrate: "substrate1",
    };
    const sample2 = {
      id: 2,
      status: "status2",
      primers: ["primer1"],
      substrate: "substrate1",
    };
    const sample3 = {
      id: 3,
      status: "status1",
      primers: ["primer2"],
      substrate: "substrate1",
    };
    const sample4 = {
      id: 4,
      status: "status1",
      primers: ["primer1"],
      substrate: "substrate2",
    };
    const sample5 = {
      id: 5,
      status: "status2",
      primers: ["primer1", "primer2"],
      substrate: "substrate2",
    };
    const sample6 = {
      id: 6,
      status: "status3",
      primers: ["primer3"],
      substrate: "substrate3",
    };
    const samples = [sample1, sample2, sample3, sample4, sample5, sample6];

    describe("status filter", () => {
      it("filters samples by status", () => {
        const filters = { status: "status1" };

        expect(subject(filters, samples)).toEqual([sample1, sample3, sample4]);
      });

      it('ignores "all" status', () => {
        const filters = { status: "all" };
        expect(subject(filters, samples)).toEqual(samples);
      });

      it('ignores "" status', () => {
        const filters = { status: "" };
        expect(subject(filters, samples)).toEqual(samples);
      });
    });

    describe("primer filter", () => {
      it("filters samples by primers when there is one primer", () => {
        const filters = { primer: ["primer1"] };
        expect(subject(filters, samples)).toEqual([
          sample1,
          sample2,
          sample4,
          sample5,
        ]);
      });

      it("filters samples by primers when there are multiple primers", () => {
        const filters = { primer: ["primer1", "primer2"] };
        expect(subject(filters, samples)).toEqual([
          sample1,
          sample2,
          sample3,
          sample4,
          sample5,
        ]);
      });

      it("ignores 'all' primer", () => {
        const filters = { primer: ["all"] };
        expect(subject(filters, samples)).toEqual(samples);
      });

      it("ignores '[]' primer", () => {
        const filters = { primer: [] };
        expect(subject(filters, samples)).toEqual(samples);
      });
    });

    describe("substrate filter", () => {
      it("filters samples by substrate when there is one substrate", () => {
        const filters = { substrate: ["substrate1"] };
        expect(subject(filters, samples)).toEqual([sample1, sample2, sample3]);
      });

      it("filters samples by substrate when there are multiple substrates", () => {
        const filters = { substrate: ["substrate1", "substrate2"] };
        expect(subject(filters, samples)).toEqual([
          sample1,
          sample2,
          sample3,
          sample4,
          sample5,
        ]);
      });

      it("ignores 'all' substrate", () => {
        const filters = { substrate: ["all"] };
        expect(subject(filters, samples)).toEqual(samples);
      });

      it("ignores '[]' substrate", () => {
        const filters = { substrate: [] };
        expect(subject(filters, samples)).toEqual(samples);
      });
    });

    describe("multiple filters", () => {
      it("ignores 'all' filters", () => {
        const filters = { substrate: ["all"], primer: ["all"], status: "all" };
        expect(subject(filters, samples)).toEqual(samples);
      });

      it("handles substrate, primer and status filters", () => {
        const filters = {
          substrate: ["substrate1"],
          primer: ["primer1"],
          status: "status1",
        };
        expect(subject(filters, samples)).toEqual([sample1]);
      });

      it("handles substrate and primer filters", () => {
        const filters = {
          substrate: ["substrate1"],
          primer: ["primer1"],
          status: "all",
        };
        expect(subject(filters, samples)).toEqual([sample1, sample2]);
      });

      it("handles substrate and status filters", () => {
        const filters = {
          substrate: ["substrate1"],
          primer: ["all"],
          status: "status1",
        };
        expect(subject(filters, samples)).toEqual([sample1, sample3]);
      });

      it("handles primer and status filters", () => {
        const filters = {
          substrate: ["all"],
          primer: ["primer1"],
          status: "status1",
        };
        expect(subject(filters, samples)).toEqual([sample1, sample4]);
      });
    });
  });
});
