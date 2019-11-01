export function formatQuerystring(filters) {
  let query = [];
  for (let key in filters) {
    if (filters[key].length > 0) {
      query.push(`${key}=${filters[key].join("|")}`);
    }
  }
  return query.join("&");
}

export function addSubmitHandler(initApp, endpoint, fetchFilters) {
  const submitEl = document.querySelector(".js-submit-filters");
  if (submitEl) {
    submitEl.addEventListener("click", event => {
      event.preventDefault();

      const filters = fetchFilters();
      let url = `${endpoint}?${formatQuerystring(filters)}`;
      initApp(url);
    });
  }
}

export function addSubmitSearchHandler(
  initApp,
  endpoint,
  fetchFilters,
  setFilters
) {
  const submitEl = document.querySelector(".js-submit-search");
  if (submitEl) {
    submitEl.addEventListener("click", event => {
      event.preventDefault();
      const keyword = document.querySelector("#query").value;

      const filters = fetchFilters();
      filters["keyword"] = [keyword];
      setFilters(filters);

      let url = `${endpoint}?${formatQuerystring(filters)}`;
      initApp(url);
    });
  }
}

export function addResetHandler(initApp, endpoint, resetFilters) {
  const submitEl = document.querySelector(".js-reset-filters");
  if (submitEl) {
    submitEl.addEventListener("click", event => {
      event.preventDefault();

      resetFilters();

      let url = endpoint;
      initApp(url);

      document.querySelectorAll("input").forEach(el => {
        if (el.value === "all") {
          el.checked = true;
        } else if (el.name === "taxon_rank" && el.value === "phylum") {
          el.checked = true;
        } else {
          el.checked = false;
        }
      });
    });
  }
}

export function uncheckCheckboxesHandler(optionEls, inputName) {
  optionEls.forEach(el => {
    if (el.value !== "all" && inputName === el.name) {
      el.checked = false;
    }
  });
}

export function uncheckAllHandler(optionEls, inputName) {
  optionEls.forEach(el => {
    if (el.value === "all" && inputName === el.name) {
      el.checked = false;
    }
  });
}

export function addOptionsHander(optionEls, fetchFilters, setFilters) {
  optionEls.forEach(el => {
    el.addEventListener("click", event => {
      const filters = fetchFilters();
      let currentFilters = filters[event.target.name];

      if (event.target.type === "radio") {
        filters[event.target.name] = [event.target.value];
      } else {
        if (event.target.checked) {
          if (event.target.value == "all") {
            currentFilters = [];
            uncheckCheckboxesHandler(optionEls, event.target.name);
          } else {
            currentFilters.push(event.target.value);
            uncheckAllHandler(optionEls, event.target.name);
          }
        } else {
          if (event.target.value !== "all") {
            let index = currentFilters.indexOf(event.target.value);
            if (index > -1) {
              currentFilters.splice(index, 1);
            }
          }
        }
        filters[event.target.name] = [...new Set(currentFilters)];
      }
      setFilters(filters);
    });
  });
}
