(function(){

  var batchActionHandler = function(event) {
    var action = event.target.dataset['action'];
    var checkboxes = document.getElementsByName('row');
    var ids = [];

    checkboxes.forEach(function(checkbox) {
      if (checkbox.checked) {
        ids.push(checkbox.value)
      }
    })

    var data = { batch_action: { ids: ids } };

    var successHandler = function(message) {
      window.location.reload();
    }

    $.ajax({
      type: "POST",
      url: "/admin/batch_" + action,
      data: data,
      success: successHandler
    });
  };

  var actions = document.querySelectorAll('.batch-action');
  actions.forEach(function(actionEl){
    actionEl.addEventListener('click', batchActionHandler);
  })

  function toggle() {
    var checkboxes = document.getElementsByName('row');

    checkboxes.forEach(function(checkbox) {
      checkbox.checked = checkboxToggler.checked;
    })
  }

  var checkboxToggler = document.getElementsByName('rows')[0];
  checkboxToggler.addEventListener('click', toggle);

})()
