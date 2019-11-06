import { samplesDefaultFilters } from "./constants";

export const allSamplesStore = {
  state: {
    currentFilters: { ...samplesDefaultFilters }
  },
  setPrimerArray,
  setPrimerString
};

function setPrimerArray(e) {
  let filterType = e.target.dataset["filterType"];
  let currentFilters = this.state.currentFilters;
  let value = e.target.value;

  if (value == "all") {
    currentFilters[filterType] = ["all"];
  } else if (e.target.checked) {
    if (currentFilters[filterType].includes("all")) {
      currentFilters[filterType] = [];
    }
    currentFilters[filterType].push(value);
  } else {
    currentFilters[filterType] = currentFilters[filterType].filter(
      f => f != value
    );
  }
}

function setPrimerString(e) {
  let filterType = e.target.dataset["filterType"];
  let currentFilters = this.state.currentFilters;
  let value = e.target.value.trim();

  currentFilters[filterType] = value;
}
