  // Loader.
  $('body').append(
    '<div class="loading_background">' + 
      '<div class="loading_foreground">' +
        '<div class="loading_animation"></div>' +
        '<div class="loading_title">ShinyQuickStarter</div>' +
      '</div>' +
    '</div>'
  );

$(window).on('load', function(){

  // Document.
  $(document).ready(function() {
    
    $( "#navigation_tree" ).treegrid({ });
    
    
    // Browser interactions.
    $(window).resize(function() {
      resize_to_fullscreen();
    });
    
  
    // Shiny interactions.
    Shiny.addCustomMessageHandler("set_draggable", function(message) {
      $( message.selector ).draggable({
        helper: "clone"
      });
    });
  
    
    Shiny.addCustomMessageHandler("set_droppable", function(selector) {
      $( selector ).droppable({
        accept: ".sqs_ui_type",
        tolerance: "pointer",
        greedy: true,
        drop: drop_function,
        over: function() {
          $(".sqs_over").removeClass('sqs_over');
          $(this).addClass("sqs_over");
        },
        out: function() {
          $(".sqs_over").removeClass('sqs_over');
          $(this).parent().closest(".ui-droppable").addClass("sqs_over");
        }
      });
    });
    
    
    Shiny.addCustomMessageHandler("set_sortable", function(message) {
      $( message.selector ).sortable({
        items: "div .sqs_ui_element",
        update: update_function
      });
    });
    
    
    Shiny.addCustomMessageHandler("remove_class", function(class_name) {
      $( "." + class_name ).removeClass(class_name);
    });
    
    
    Shiny.addCustomMessageHandler("highlight", function(message) {
      // Highlight in drop_zone.
      $( ".sqs_highlight" ).removeClass("sqs_highlight");
      $( "div[sqs_id='" + message.sqs_id + "']").addClass("sqs_highlight");
      
      // Highlight in navigation tree.
      $( "#navigation_tree" ).treegrid( "unselectAll" );
      $( "#navigation_tree" ).treegrid("select", message.id);
    });
    
  
    Shiny.addCustomMessageHandler("edit_mode", function(edit_mode) {
      if (edit_mode) {
        $('.sqs_ui_element_header').css('display', 'inline-block');
        $('.sqs_ui_element_body').css('border-style', 'solid');
        
        $( '#sqs_page_type' ).prop('disabled', false);
        $( '#sqs_page_type' ).selectpicker('refresh');
      } else {
        $('.sqs_ui_element_header').css('display', 'none');
        $('.sqs_ui_element_body').css('border-style', 'none');
        
        $( '#sqs_page_type' ).prop('disabled', true);
        $( '#sqs_page_type' ).selectpicker('refresh');
      }
    });
    
    
    Shiny.addCustomMessageHandler("insert_validations", function(message) {
      $div = $( "div[sqs_id='option_zone'] #" + message.name ).closest( ".row" ).find( ".col-sm-8 .sqs_validation" );
      $div.text(message.validation_error);
    });
    
    
    Shiny.addCustomMessageHandler("remove_validations", function(message) {
      $( ".sqs_validation" ).text("");
    });
    
    
    Shiny.addCustomMessageHandler("update_sqs_id", function(message) {
      $( "div[sqs_id=" + message.old_sqs_id + "]" ).attr("sqs_id", message.new_sqs_id);
    });
    
    
    Shiny.addCustomMessageHandler("add_sqs_class", function(sqs_id) {
      $( "div[sqs_id=" + sqs_id + "]" ).addClass("sqs_ui_element");
    });
    
    
    Shiny.addCustomMessageHandler("update_tree", function(message) {
      $( "#navigation_tree" ).treegrid({
        data: [message.data],
        lines: true,
        rownumbers: true,
        idField: 'id',
        treeField: 'name',
        columns:[[
          {title: 'UI Element', field: 'name'},
          {title: 'Id', field: 'uia_id'},
          {title: 'Title', field: 'uia_title'}
        ]],
        onContextMenu: show_navigation_tree_context_menu,
  	    onClickRow: highlight_from_navigation_tree,
  	    onCollapse: delete_tree_icons,
  	    onExpand: delete_tree_icons,
  	    onLoadSuccess: delete_tree_icons,
      });
    });
  
    
    Shiny.addCustomMessageHandler("set_shinydashboard", function(message) {
      if (message.dashboardPage_skin.length !== 0) {
        var classes = $( "body" ).attr( "class" ).split(" ");
        old_skins = classes.filter(value => /^skin-.*/.test(value));
  
        if (old_skins[0] !== "skin-" + message.dashboardPage_skin) {
          var $items = $( "." + old_skins[0] );
        
          for (var i = 0; i < old_skins.length; i++) {
            $items.removeClass( old_skins[i] );
          }
        
          $items.addClass( "skin-" + message.dashboardPage_skin);
        }
      }
      
      new_style = "";
      if (message.dashboardHeader_titleWidth.length !== 0) {
        new_style = "div[sqs_id=drop_zone] .main-header .logo {" +
          "width:" + message.dashboardHeader_titleWidth + 
        "}" + 
        "div[sqs_id=drop_zone] .main-header .navbar {" +
          "margin-left:" + message.dashboardHeader_titleWidth + 
        "}";
      }
        
      if (message.dashboardSidebar_width.length !== 0) {
        new_style = new_style + 
        ".sidebar-collapse .content-wrapper, .sidebar-collapse .main-footer, .sidebar-collapse .right-side {" +
          "margin-left: 0px !important;" +
        "}" +
        ".sidebar-collapse .main-sidebar, .sidebar-collapse .left-side {" +
          "-webkit-transform: translate(-" + message.dashboardSidebar_width + ", 0);" +
          "-ms-transform: translate(-" + message.dashboardSidebar_width + ", 0);" +
          "-o-transform: translate(-" + message.dashboardSidebar_width + ", 0);" +
          "transform: translate(-" + message.dashboardSidebar_width + ", 0);" +
        "}" +
        "div[sqs_id=drop_zone] .left-side, .main-sidebar {" +
          "width:" + message.dashboardSidebar_width + 
        "}";
        
        if (message.dashboardSidebar_collapsed === "TRUE" |
            message.dashboardSidebar_disable === "TRUE") {
          new_style = new_style + 
          "div[sqs_id=drop_zone] .content-wrapper, .right-side, .main-footer {" +
            "margin-left:0px"  +
          "}";
        } else {
          new_style = new_style + 
          "div[sqs_id=drop_zone] .content-wrapper, .right-side, .main-footer {" +
            "margin-left:" + message.dashboardSidebar_width +
          "}";
        }
      }
      
      $( "#style_changer" ).html(new_style);
      
      if (message.dashboardSidebar_disable === "TRUE") {
        $( ".navbar-static-top > a" ).css("display", "none");
        $( "body" ).addClass("sidebar-collapse");
      } else {
        if (message.dashboardSidebar_collapsed === "TRUE") {
          $( "body" ).addClass("sidebar-collapse");
        } else if (message.dashboardSidebar_collapsed === "FALSE") {
          $( "body" ).removeClass("sidebar-collapse");
        }
      }
      
      $( "div[sqs_id=drop_zone] #sidebarCollapsed ul" ).each(function( index ) {
        if (message.menuItem_startExpanded[index] == "TRUE") {
          $(this).addClass("menu-open");
          $(this).children("ul").css("display", "block");
        } else {
          $(this).removeClass("menu-open");
          $(this).children("ul").css("display", "none");
        }
      });
  
    });
    
    
    Shiny.addCustomMessageHandler("click_href", function(message) {
      $( "a[href='" + message + "']" ).css("display", "block");
      $( "a[href='" + message + "']" ).click();
    });
    
    
    Shiny.addCustomMessageHandler("hide_badges", function(message) {
      $( "p.sqs_ui_type" ).show();
      
      for (var i=0; i < message.length; i++) {
        $( "p[rel=" + message[i] + "]" ).attr("sqs_show", false);
        $( "p[rel=" + message[i] + "]" ).hide();
      }
    });
    
  
    Shiny.addCustomMessageHandler('setInputValues', function(names) {
      for (var i=0; i < names.length; i++) {
        Shiny.setInputValue(
          id = names[i], 
          value = "INVALID!"
        );
      }
    });
    
    
    Shiny.addCustomMessageHandler("set_sortable", function(message) {
      $( message.selector ).sortable({
        items: "div .sqs_ui_element",
        update: update_function
      });
    });
    
    
    Shiny.addCustomMessageHandler("show_tabs", function(message) {
  
      if (!$.isArray(message.hide)) {
        if (message.hide === null) {
          message.hide = [];
        } else {
          message.hide = [message.hide];
        }
      }
      if (!$.isArray(message.show)) {
        message.show = [message.show];
      }
      
      for (i=0; i < message.show.length; i++) {
        $( message.id ).tabs("enableTab", message.show[i]);
        if (i === 0) {
          $( message.id ).tabs("select", message.show[i]);
        }
      }
      
      for (var i=0; i < message.hide.length; i++) {
        $( message.id ).tabs("disableTab", message.hide[i]);
      }
  
    });
    
    
    Shiny.addCustomMessageHandler("stop_addin", function(message) {
      $( 'body' ).append('<div id=\'#shiny-disconnected-overlay\'></div>');
    });
  
    
    // User interactions.
    $( "body" ).click( function( event ) {
      if ($("#edit_mode").prop('checked')) {
        if (event.ctrlKey) {
          remove_ui_element(event);
        }
      }
    });
    
    
    $( "body" ).click( function( event ) {
      if ($("#edit_mode").prop("checked")) {
        if (!event.ctrlKey) {
          highlight_ui_element(event);
        }
      }
    });
  
    
    $( "#search_box" ).on("change keyup paste", function(){
      search = $( "#search_box" ).val().toLowerCase();
  
      $( "#UI_Layout > p[sqs_show!='false'], \
          #UI_Inputs > p[sqs_show!='false'], \
          #UI_Outputs > p[sqs_show!='false']" ).filter(function() {
        $(this).toggle($(this).text().toLowerCase().indexOf(search) > -1);
      });
    });
    
    
    $( ".add_navigation" ).click( function( event ) {
      var sqs_type = $(event.target).text();
      var parent = $('#navigation_tree').treegrid('getSelected').sqs_id;
  
      Shiny.setInputValue(
        id = "insert_ui", 
        value = { 
          sqs_id: Math.random(),
          parent: parent,
          sqs_type: sqs_type,
          highlight: true
        }
      );
    });
    
    
    $( ".remove_navigation" ).click( function( event ) {
      var sqs_id = $('#navigation_tree').treegrid('getSelected').sqs_id;
      var sqs_type = $('#navigation_tree').treegrid('getSelected').name;
  
      Shiny.setInputValue(
        id = "remove_ui", 
        value = { sqs_id: sqs_id }
      );
      Shiny.setInputValue(
        id = "show_ui_options", 
        value = { sqs_id: null }
      ); 
    });
    
    
    $( "#right_tabs" ).tabs({
      onSelect: function(title, index){
        Shiny.setInputValue(
          id = "update_displayed_tabs", 
          value = Math.random()
        );
      }
    });
    
    
    // Info Overlay.
    $( "#info" ).click( function( event ) {
      
      event.preventDefault();
      
      Shiny.setInputValue(
        id = "help_tour_start",
        value = Math.random()
      );

      current_drop_zone = $( 'div[sqs_id=drop_zone_content]' ).html();
  
      // Define the steps for introduction
      const driver = new Driver({
        opacity: 0.65,
        padding: 5,
        onReset: () => {
          Shiny.setInputValue(
            id = "remove_ui",
            value = { sqs_id: "ui_1", update: Math.random()}
          ); 
        },
      });
  
      driver.defineSteps(tour_steps(driver));
      
      // Start the introduction
      driver.start();

    });
    
  });


  setTimeout(function() {
    $( ".loading_background" ).fadeOut(500, function() {
      $( ".loading_background" ).remove();
    });
    
    setTimeout(function() {
      $( "#info" ).click();
    }, 1000);
  }, 2500);
  
});


// Resize at start.
$(window).on('pageshow', function(){
  resize_to_fullscreen();
});


