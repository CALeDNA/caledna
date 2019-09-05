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
