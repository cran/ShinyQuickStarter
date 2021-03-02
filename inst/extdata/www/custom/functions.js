function resize_to_fullscreen() {
  var window_height = $(window).height();
  var window_width = $(window).width();

  $( "#layout" ).height(window_height);
  $( "#layout" ).width(window_width);
}


function drop_function(event, ui) {
  var $item = $(ui.helper).clone();
  var $drop = $(this);
  if ( $drop.attr( "sqs_id" ) !== "drop_zone" ) { 
    $drop = $drop.closest(".sqs_ui_element");
  }

  sqs_id = $item.attr("sqs_id");
  
  if (typeof sqs_id !== typeof undefined && sqs_id !== false) {
    Shiny.setInputValue(
      sqs_id = "move_ui",
      value = { sqs_id: $item.attr("sqs_id"), parent: $drop.attr("sqs_id") }
    );    
  } else {
    var sqs_type = $item.attr("rel");
    Shiny.setInputValue(
      sqs_id = "insert_ui",
      value = { 
        sqs_id: Math.random(),
        parent: $drop.attr("sqs_id"),
        sqs_type: sqs_type,
        highlight: true
      }
    );
  }
  
  $(".sqs_over").removeClass('sqs_over');
}


function update_function(event, ui) {
  Shiny.setInputValue(
    id = "move_ui",
    value = { sqs_ids: $(this).sortable("toArray", {attribute: "sqs_id"}) }
  );
}


function remove_ui_element(event) {
  var $item = $(event.target);
  var $sqs = $item.closest(".sqs_ui_element");

  if ($sqs.length !== 0) {
    Shiny.setInputValue(
      id = "remove_ui", 
      value = { sqs_id: $sqs.attr("sqs_id") }
    );
    Shiny.setInputValue(
      id = "show_ui_options", 
      value = { sqs_id: null }
    );
  }
}


function highlight_ui_element(event) {
  var $item = $(event.target);
  var $sqs = $item.closest(".sqs_ui_element");
  
  var classes = $item.attr("class");
  
  // Check if info.
  var info = $item.closest("div[id=driver-popover-item]");
  
  if (info.length === 0) {
    if ( typeof classes !== typeof undefined) {
      if ( classes.indexOf('sqs_ui_element_header') !== -1 ) {
        Shiny.setInputValue(
          id = "show_ui_options", 
          value = { sqs_id: $sqs.attr("sqs_id"), sqs_type: $sqs.attr("sqs_type"), update: Math.random() }
        );
      } else {
        sqs_id = $item.closest("div[sqs_id]").attr("sqs_id");
  
        if ( sqs_id !== "option_zone" & sqs_id !== "navigation" & sqs_id !== "code_zone" ) {
          Shiny.setInputValue(
            id = "show_ui_options", 
            value = { sqs_id: null, type: "", update: Math.random()}
          );
        }
      }
    }
  }
}


function show_navigation_tree_context_menu(e, row){
  e.preventDefault();
  $( "#navigation_tree" ).treegrid('select', row.id);

  if ( typeof row.removable != 'undefined' ) {
    if ( row.removable ) {
      $( ".remove_navigation" ).show();
    } else {
      $( ".remove_navigation" ).hide();
    }
  }

  if ( typeof row.possible_add == 'undefined' ) {
    $( ".add_menu" ).hide();
  } else {
    $( ".add_menu" ).show();
    $( ".add_navigation" ).each(function () {
      if ( row.possible_add.indexOf($(this).text()) !== -1 ) {
        $(this).show();
      } else {
        $(this).hide();
      }
    });
  }

  if (!(row.removable === false & typeof row.possible_add == "undefined")) {
    $( '#context_menu_navigation_tree' ).menu('show', {
      left: e.pageX,
      top: e.pageY
    });
  }
}


function highlight_from_navigation_tree(row) {
  Shiny.setInputValue(
    id = "show_ui_options", 
    value = { sqs_id: row.sqs_id, sqs_type: row.name, update: Math.random() }
  );
}


function delete_tree_icons() {
  $( ".tree-file" ).removeClass( "tree-file" );
  $( ".tree-folder" ).removeClass( "tree-folder" );
  $( ".tree-folder-open" ).removeClass( "tree-folder-open" );
}


function move_in_navigation_tree(targetRow, sourceRow, point) {
  alert(targetRow + ':' + sourceRow + ':' + point);
}


function update_function(event, ui) {
  Shiny.setInputValue(
    id = "move_ui",
    value = { sqs_ids: $(this).sortable("toArray", {attribute: "sqs_id"}) }
  );
}


