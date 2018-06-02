(function(){
  var batchActionHandler = function(event) {
    var action = event.target.dataset['action'];
    var checkboxes = document.getElementsByName('batch_ids[]');
    var associatedDataEl = document.getElementById('associated_data');
    var associatedData = associatedDataEl ? associatedDataEl.dataset['data'] : null;
    var ids = [];

    checkboxes.forEach(function(checkbox) {
      if (checkbox.checked) {
        ids.push(checkbox.value)
      }
    })

    var data = { batch_action: { ids: ids, data: associatedData } };
    var successHandler = function(message) {
      window.location.reload();
    }

    $.ajax({
      type: "POST",
      url: "/admin/labwork/batch_" + action,
      data: data,
      success: successHandler
    });
  };

  var actions = document.querySelectorAll('.batch-action');
  if (actions) {
    actions.forEach(function(actionEl){
      actionEl.addEventListener('click', batchActionHandler);
    })
  }

  function toggle() {
    var checkboxes = document.querySelectorAll('.row');

    checkboxes.forEach(function(checkbox) {
      checkbox.checked = checkboxToggler.checked;
    })
  }

  var checkboxToggler = document.getElementsByName('rows')[0];
  if (checkboxToggler) {
    checkboxToggler.addEventListener('click', toggle);
  }

})()
