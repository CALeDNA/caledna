export const searchMixins = {
  methods: {
    formatCurrentFiltersDisplay(filters) {
      return this.flattenCurrentFilters(filters).join(", ");
    },
    flattenCurrentFilters(filters) {
      let displayFilters = [];

      for (let key in filters) {
        let filter = filters[key];
        if (filter == "all") {
          continue;
        }
        if (typeof filter === "string" && filter.trim() !== "") {
          displayFilters.push(filter.trim());
        } else if (Array.isArray(filter)) {
          displayFilters = displayFilters.concat(filter);
        }
      }
      return displayFilters;
    },
    filterSamples(filters, samples) {
      if (filters.status && filters.status !== "all") {
        samples = samples.filter((sample) => {
          return filters.status == sample.status_cd;
        });
      }

      if (
        filters.substrate &&
        !filters.substrate.includes("all") &&
        filters.substrate.length > 0
      ) {
        samples = samples.filter((sample) => {
          return filters.substrate.includes(sample.substrate_cd);
        });
      }

      if (
        filters.primer &&
        !filters.primer.includes("all") &&
        filters.primer.length > 0
      ) {
        samples = samples.filter((sample) => {
          return filters.primer.some((primer) => {
            const primer_ids = sample.primer_ids ? sample.primer_ids : [];
            return primer_ids.includes(Number(primer));
          });
        });
      }

      return samples;
    },
  },
};
