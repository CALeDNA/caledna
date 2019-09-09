var kingdoms = [
  "Animalia",
  "Archaea",
  "Bacteria",
  "Chromista",
  "Fungi",
  "Plantae",
  "Protozoa",
  "Environmental_samples"
];

var buttonEls = document.querySelectorAll(".kingdom-submenu a");

if (buttonEls) {
  var itemElsObj = {};
  kingdoms.forEach(kingdom => {
    itemElsObj[kingdom] = document.querySelectorAll(`.${kingdom}.item`);
  });

  buttonEls.forEach(el => {
    el.addEventListener("click", e => {
      e.preventDefault();
      var targetKingdom = e.target.dataset.kingdom;

      kingdoms.forEach(kingdom => {
        var kindomEls = itemElsObj[kingdom];

        if (targetKingdom == "All") {
          kindomEls.forEach(el => (el.style.display = "list-item"));
        } else if (kingdom == targetKingdom) {
          kindomEls.forEach(el => (el.style.display = "list-item"));
        } else {
          kindomEls.forEach(el => (el.style.display = "none"));
        }
      });
    });
  });
}
