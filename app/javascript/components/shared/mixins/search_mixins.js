export const searchMixins = {
  methods: {
    formatCurrentFiltersDisplay(filters) {
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
      return displayFilters.join(", ");
    }
  }
};
