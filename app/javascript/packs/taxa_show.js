// toogle taxonomy tree

let abridgedTaxonomyEl = document.querySelector(".js-taxonomy-abridged");
let completeTaxonomyEl = document.querySelector(".js-taxonomy-complete");
let minorRankEls = document.querySelectorAll(".js-minor-rank");

if (abridgedTaxonomyEl) {
  abridgedTaxonomyEl.addEventListener("click", e => {
    e.preventDefault();
    minorRankEls.forEach(el => (el.style.display = "none"));
    abridgedTaxonomyEl.style.display = "none";
    completeTaxonomyEl.style.display = "block";
  });
}

if (completeTaxonomyEl) {
  completeTaxonomyEl.addEventListener("click", e => {
    e.preventDefault();
    minorRankEls.forEach(el => (el.style.display = "table-row"));
    abridgedTaxonomyEl.style.display = "block";
    completeTaxonomyEl.style.display = "none";
  });
}

// toggle biotic interactions

let ednaInteractionsEl = document.querySelector(".js-interactions-edna");
let allInteractionsEl = document.querySelector(".js-interactions-all");
let zeroEdnaEls = document.querySelectorAll(".js-no-sites");

if (ednaInteractionsEl) {
  ednaInteractionsEl.addEventListener("click", e => {
    e.preventDefault();
    zeroEdnaEls.forEach(el => (el.style.display = "none"));
    ednaInteractionsEl.style.display = "none";
    allInteractionsEl.style.display = "block";
  });
}

if (allInteractionsEl) {
  allInteractionsEl.addEventListener("click", e => {
    e.preventDefault();
    zeroEdnaEls.forEach(el => (el.style.display = "list-item"));
    ednaInteractionsEl.style.display = "block";
    allInteractionsEl.style.display = "none";
  });
}
