// rails-ujs is bundled with Rails 5.1
//= require rails-ujs

// jquery and bootstrap-sprockets needed for bootstrap-sass
//= require jquery
//= require bootstrap-sprockets

// photoswipe is an image gallery
//= require photoswipe

//= require font_awesome5
//= require trix

//= require_tree .

$(function () {
  // setup clickable rows
  function clickableTableRows() {
    function clickRow(el) {
      el.addEventListener("click", function (e) {
        e.stopPropagation();
        window.location = el.parentElement.dataset["path"];
      });
    }

    document.querySelectorAll(".clickable_row td").forEach(clickRow);
  }

  clickableTableRows();
});
