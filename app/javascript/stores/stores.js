import { samplesDefaultFilters, taxaDefaultFilters } from "../constants";

export const allSamplesStore = {
  state: {
    currentFilters: { ...samplesDefaultFilters },
  },
  setPrimerArray,
  setPrimerString,
};

export const completedSamplesStore = {
  state: {
    currentFilters: { ...taxaDefaultFilters },
  },
  setPrimerArray,
};

export const inatStore = {
  hexagonIdInat: null,
  hexagonIdExplorer: null,
  openCount: 0,
  logger: function(caller, id) {
    return;
    console.log(
      caller,
      "click",
      id,
      "exp",
      this.hexagonIdExplorer,
      "inat",
      this.hexagonIdInat,
      "count",
      this.openCount
    )
  },
  reset: function() {
    this.hexagonIdInat = null;
    this.hexagonIdExplorer = null;
    this.openCount = 0;
  },
  popupsExist: function() {
    return this.openCount > 0
  },
  openExplorerWatchMap: function() {
    let check1 = this.openCount <= 3 &&
      this.hexagonIdInat != this.hexagonIdExplorer;

    let check2 = this.openCount < 3 &&
      this.hexagonIdInat == this.hexagonIdExplorer;

    return check1 || check2
  },
  openInatMap: function() {
    let check1 =
      this.openCount === 1 &&
      this.hexagonIdInat &&
      !this.hexagonIdExplorer;

    let check2 =
      this.openCount === 2 &&
      this.hexagonIdInat &&
      this.hexagonIdExplorer;

    return check1 || check2
  },
  openInatWatchMap: function() {
    let check1 =
      this.openCount <= 3 &&
      this.hexagonIdInat !== this.hexagonIdExplorer;

    return check1
  }
}

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
      (f) => f != value
    );
  }
}

function setPrimerString(e) {
  let filterType = e.target.dataset["filterType"];
  let currentFilters = this.state.currentFilters;
  let value = e.target.value.trim();

  currentFilters[filterType] = value;
}
