// JS for submitting forms with return.
$(document).keyup(function(e) {

  if (($("#navigation_id").is(":focus") || $("#navigation_title").is(":focus") ||
       $("#navigation_position").is(":focus")) && (e.key == "Enter")) {

         if ($("#navigation_form_mode").text() == "add") {
           $("#button_navigation_add").click();
         } else if ($("#navigation_form_mode").text() == "edit") {
           $("#button_navigation_edit").click();
         }

  }
});

$(document).keyup(function(e) {
  if (($("#module_id").is(":focus") || $("#module_return").is(":focus")) && (e.key == "Enter")) {

         if ($("#module_form_mode").text() == "add") {
           $("#button_module_add").click();
         } else if ($("#module_form_mode").text() == "edit") {
           $("#button_module_edit").click();
         }

  }
});

$(document).keyup(function(e) {
  if (($("#navigation_module_navigation_id").is(":focus") || $("#navigation_module_module_id").is(":focus") ||
       $("#navigation_module_instance_id").is(":focus")) && (e.key == "Enter")) {

         if ($("#navigation_module_form_mode").text() == "add") {
           $("#button_navigation_module_add").click();
         } else if ($("#navigation_module_form_mode").text() == "edit") {
           $("#button_navigation_module_edit").click();
         }

  }
});


// JS for navigating between input fields.
$(document).keyup(function(e) {

  // Down Key.
  if (e.keyCode === 40) {
    e.preventDefault();
    if ($("#navigation_position").is(":focus")) {
      $("#navigation_title").focus();
    } else if ($("#navigation_title").is(":focus")) {
      $("#navigation_id").focus();
    }
  }

  // Up Key.
  if (e.keyCode === 38) {
    e.preventDefault();
    if ($("#navigation_id").is(":focus")) {
      $("#navigation_title").focus();
    } else if ($("#navigation_title").is(":focus")) {
      $("#navigation_position").focus();
    }
  }

});


$(document).keyup(function(e) {

  // Down Key.
  if (e.keyCode === 40) {
    e.preventDefault();
    if ($("#module_id").is(":focus")) {
      $("#module_return").focus();
    }
  }

  // Up Key.
  if (e.keyCode === 38) {
    e.preventDefault();
    if ($("#module_return").is(":focus")) {
      $("#module_id").focus();
    }
  }

});

