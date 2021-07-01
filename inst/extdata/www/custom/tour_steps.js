function tour_steps(driver) {
  var steps = [
  // 1 Welcome.
  {
    element: '#info',
    popover: {
      title: 'Tour',
      description: '<p>Welcome to the <code>ShinyQuickStarter</code>!<p> \
   <p>The following tour gives you a quick overview about what this addin can do and how to use it.</p> \
   <p>General background knowledge of the fundamentals of Shiny is highly recommended:<p> \
   <p><a href="https://Shiny.rstudio.com/tutorial/" target="_blank">https://Shiny.rstudio.com/tutorial/<a/></p>',
      position: 'right'
    }
  },

  // Left Side.
  // 2 Page Type.
  {
    element: '#info_sqs_page_type',
    popover: {
	    className: "step_popover_60",
	    title: 'Page Types<p class="info_step_number">1/21</p>',
	    description: '<p>As a first step you should choose a suitable page type.<p> \
   <p>The page type can largely influence the design and the navigation within your Shiny app.</p> \
   <p><b>Disclaimer:</b> Changing the page type will remove all UI Elements within the Droparea.</p> \
   <p><b>Page Types without a top-level navigation:</b></p> \
   <ul> \
    <li><b>fluidPage</b> scales the components in realtime to fill all available browser width.</li> \
    <li><b>fillPage</b> creates an app whose height and width always fills the available area in the browser window.</li> \
    <li><b>fixedPage</b> limits the app width to 940px on a typical, 724px on a smaller and 1170px on a larger display.</li> \
    <li><b>bootstrapPage</b> loads the bootstrap css/js.</li> \
   </ul> \
    <p><b>Page Types with a top-level navigation:</b></p> \
   <ul> \
     <li><b>navbarPage</b> creates an app that contains a top level navigation bar.</li> \
     <li><b>dashboardPage</b> creates an app that contains a top level sidebar.</li> \
     <li><b>miniPage</b> creates an app that contains a top level navigation menu and works well on smaller screens.</li> \
   </ul> \
   <p><b>Module</b></p> \
   <ul> \
     <li><b>tagList</b> creates a module that can be included in a Shiny app. For more informations about modules visit \
     <a href="https://Shiny.rstudio.com/articles/modules.html" target="_blank">https://Shiny.rstudio.com/articles/modules.html</a></li> \
   </ul>',
	    position: 'right'
    }
  },
  // 3 Navigation Tree.
  {
    element: '#info_navigation_tree',
    popover: {
	    className: "step_popover_60",
	    title: 'Navigation Tree<p class="info_step_number">2/21</p>',
	    description: '<p>The Navigation Tree shows you a nested overview over all UI Elements in your Shiny app. \
   Additionally, important ids are displayed for UI Elements for which one can be specified.</p> \
   <p>When <b>selecting</b> an UI Element in the tree, it will be highlighted in the Droparea.</p> \
   <p>You can <b>remove</b> an UI Element via the context menu. \
   Removing an UI Element will also remove all child UI Elements.</p> \
   <p>The icons <span class="fa fa-file-code"></span> and <span class="fa fa-bars"></span> show \
   where Navigation Elements can be added via the context menu.</p> \
   <ul> \
    <li><code>navlistPanel</code>, <code>tabsetPanel</code>, <code>tabBox</code> are included as \
    low-level Navigation Elements. </li> \
    <li>In a <b>navbarPage</b> the Navigation Elements <code>tabPanel</code> and <code>navbarMenu</code> \
    are used for top-level navigation.</li> \
    </li> \
    <li>In a <b>dashboardPage</b> you can create the top-level navigation by adding <code>menuItem</code> \
    Elements to <code>sidebarMenu</code>, adding <code>tabItem</code> Elements to <code>tabItems</code> \
    and connecting them by using the <code>tabName</code> argument in the Options panel. If your sidebar is \
    nested, you can only connect a <code>tabItem</code> to the lowest <code>menuItem</code> Elements. \
    </li> \
    <li> In a <b>miniPage</b> the top level navigation consists of <code>miniTabPanel</code> Elements, \
    that are nested within a <code>miniTabstripPanel</code> Element.</li> \
   </ul>',
	    position: 'right'
    }
  },
  // 4 Search box.
  {
    element: 'div[sqs_id=ui_element_zone] .panel:nth-child(1)',
    popover: {
      className: "step_popover_40",
	    title: 'Search Box<p class="info_step_number">3/21</p>',
	    description: '<p>Here you can filter the UI Elements by some search term e.g. \'button\' or \'ShinyWidgets\'.</p>',
	    position: 'right'
    },
    onNext: () => {
	    driver.preventMove();
	    $( 'div[sqs_id=ui_element_zone] .panel:nth-child(2) a.panel-tool-expand' ).click();
	    driver.moveNext();
    }
  },
  // 5 UI Layout.
  {
    element: 'div[sqs_id=ui_element_zone] .panel:nth-child(2)',
    popover: {
      className: "step_popover_40",
	    title: 'UI Layout<p class="info_step_number">4/21</p>',
	    description: '<p>These UI Elements are used to control the layout of the app.</p> \
    <p>In most of the UI Layout Elements additional UI Elements can be inserted.</p>',
	    position: 'right'
    },
    onNext: () => {
	    driver.preventMove();
	    $( 'div[sqs_id=ui_element_zone] .panel:nth-child(3) a.panel-tool-expand' ).click();
	    driver.moveNext();
    }
  },
  // 6 UI Inputs.
  {
    element: 'div[sqs_id=ui_element_zone] .panel:nth-child(3)',
    popover: {
      className: "step_popover_40",
	    title: 'UI Inputs<p class="info_step_number">5/21</p>',
	    description: '<p>These UI Elements are used for user interaction with the Shiny app.</p> \
    <p>Every UI Input requires an <code>inputId</code> e.g. \'update\', which allows access \
    to the value of the UI Input in the server part of the Shiny app via <code>input$update</code>.</p>',
	    position: 'right'
    },
    onNext: () => {
	    driver.preventMove();
	    $( 'div[sqs_id=ui_element_zone] .panel:nth-child(4) a.panel-tool-expand' ).click();
	    driver.moveNext();
    }
  },
  // 7 UI Outputs.
  {
    element: 'div[sqs_id=ui_element_zone] .panel:nth-child(4)',
    popover: {
      className: "step_popover_40",
	    title: 'UI Outputs<p class="info_step_number">6/21</p>',
	    description: '<p>These UI Elements are used for displaying data via text, tables, plots, etc. to the user.</p> \
    <p>UI Outputs consist of a function in the ui part of the app e.g. <code>dataTableOutput</code> \
    and a connected function in the server part of the app e.g. <code>renderDataTable</code>.</p> \
    <p>Every UI Output requires an <code>outputId</code> which connects the functions in the ui and server.</p>',
	    position: 'right'
    }
  },
  
  // 8 Droparea.
  {
    element: 'div[sqs_id=drop_zone]',
    popover: {
	    title: 'Droparea<p class="info_step_number">7/21</p>',
	    description: '<p>The Droparea is the heart of the addin.</p> \
    <p>UI Elements in the Droparea are surrounded with a box indicating the UI Element type.<p>',
	    position: 'right'
    },
    onNext: () => {
	    driver.preventMove();
	    Shiny.setInputValue(
	      id = "insert_ui",
	      value = {
		      sqs_id: 0.1,
		      parent: $( "div[sqs_id=drop_zone_content] .sqs_ui_element.ui-droppable" ).attr("sqs_id"),
		      sqs_type: "plotlyOutput",
		      update: Math.random(),
		      highlight: false
	      }
	    );
	    driver.moveNext();
	    $( '#driver-highlighted-element-stage' ).css("height", "90%");
    }
  },
  // 9 Droparea.
  {
    element: '.drop_zone_step_2',
    popover: {
	    title: 'Inserting UI Elements<p class="info_step_number">8/21</p>',
	    description: '<p>Insert an UI Element by <b>dragging</b> it from the \'UI Elements\' panel into another UI Element in the Droparea.</p> \
    <p>Required child UI Elements will be automatically added.</p>',
	    position: 'right'
    },
    onNext: () => {
	    Shiny.setInputValue(
	      id = "show_ui_options", 
	      value = { sqs_id: "ui_1", type: "plotlyOutput", update: Math.random()}
	    );
    }
  },
  // 10 Droparea.
  {
    element: 'div[sqs_id=drop_zone]',
    popover: {
  	  title: 'Selecting UI Elements<p class="info_step_number">9/21</p>',
  	  description: '<p>Highlight an UI Element by <b>clicking</b> on the header (e.g. \
    <span class=\'tour_sqs_ui_element_header\'>plotlyOutput</span>) in the box surrounding the UI Element.</p> \
    <p>The selected UI Element is highlighted by its red border.</p>',
	    position: 'right'
    }
  },
  // 11 Droparea.
  {
    element: '.drop_zone_step_4',
    popover: {
	    title: 'Removing UI Elements<p class="info_step_number">10/21</p>',
	    description: '<p>Remove an UI Element by pressing <b>ctrl + clicking</b> on it.</p> \
    <p>This will also remove all child UI Elements.</p>',
	    position: 'right'
    }
  },
  // 12 Droparea.
  {
    element: '#edit_mode_panel',
    popover: {
	    title: 'Mode<p class="info_step_number">11/21</p>',
	    description: '<p>While in the <b>Edit Mode</b> you can insert/highlight/update/remove UI Elements from the Droparea.</p> \
    <p>If you change to the <b>Display Mode</b> the Droparea will show you how the Shiny app would look like \
    when exported. In this mode no changes are possible.</p>',
	    position: 'right'
    },
    onNext: () => {
	    driver.preventMove();
	    $( 'ul.tabs li:nth-child(1) a:first' ).click();
	    driver.moveNext();
    }
  },

  // 13 Options.
  {
    element: '#right_tabs',
    popover: {
	    className: 'right_tabs_popover',
	    title: 'Options<p class="info_step_number">12/21</p>',
	    description: '<p>This panel displays the current options of the selected UI element with their detailed documentation.</p> \
     <p>You can change the options with the respective form elements.</p> \
     <p>In case of invalid values (e.g. a non-unique <code>inputId</code>), validation errors are displayed next \
     to the form element.</p> \
     <p><b>Disclaimer:</b> For simplicity, some UI Elements do not display all the options that could actually be changed. \
     In such cases, please refer to the full documentation of the UI Elements (e.g. <code>help(renderDataTable)</code>).',
	    position: 'left'
    },
    onNext: () => {
	    driver.preventMove();
	    $( '#options_tabs li:nth-child(1) a:first' ).click();
	    driver.moveNext();
    }
  },
  // 14 Options - UI.
  {
    element: '#options_tabs',
    popover: {
	    className: 'right_tabs_ul_popover',
	    title: 'Options &rarr; UI<p class="info_step_number">13/21</p>',
	    description: '<p>These Options affect the appearance and behavior of the UI Elements in the app. They are specified in the UI function.</p>',
	    position: 'left'
    },
    onNext: () => {
	    driver.preventMove();
	    $( '#options_tabs li:nth-child(2) a:first' ).click();
	    driver.moveNext();
    }
  },
  // 15 Options - Server.
  {
    element: 'div[sqs_id=option_zone]',
    popover: {
	    className: 'right_tabs_ul_popover',
	    title: 'Options &rarr; Server<p class="info_step_number">14/21</p>',
	    description: '<p>For UI Outputs, additional Options can be set for the Server function associated with the UI function.</p> \
     <p>The <code>expr</code> of a server function contains the logic part of the app. The creation of this part cannot be automated. \
     However, this addin can be used to select from a few sample code snippets that may help with development.</p>',
	    position: 'left'
    },
    onNext: () => {
	    driver.preventMove();
	    $( '#right_tabs li:nth-child(2) a:first' ).click();
	    driver.moveNext();
    },
    onPrevious: () => {
	    driver.preventMove();
	    $( '#options_tabs li:nth-child(1) a:first' ).click();
	    driver.movePrevious();
    }
  },
  // 16 Code.
  {
    element: '#right_tabs',
    popover: {
	    className: 'right_tabs_popover',
	    title: 'Code <p class="info_step_number">15/21</p>',
	    description: '<p>In this panel the generated code is displayed.</p>',
	    position: 'left'
    },
    onNext: () => {
	    driver.preventMove();
	    $( '#code_tabs li:nth-child(1) a:first' ).click();
	    driver.moveNext();
    },
    onPrevious: () => {
	    driver.preventMove();
	    $( '#right_tabs li:nth-child(1) a:first' ).click();
	    $( '#options_tabs li:nth-child(2) a:first' ).click();
	    driver.movePrevious();
    }
  },
  // 17 Code - ui.R
  {
    element: '#code_tabs',
    popover: {
	    className: 'right_tabs_ul_popover',
	    title: 'Code &rarr; ui.R<p class="info_step_number">16/21</p>',
	    description: '<p>This is how you define the user interface of your app.</p> \
	    <p>It controls the layout and appearance and is used by Shiny to generate the \
	    necessary HTML.</p>',
	    position: 'left'
    },
    onNext: () => {
	    driver.preventMove();
	    $( '#code_tabs li:nth-child(2) a:first' ).click();
	    driver.moveNext();
    }
  },
  // 18 Code - server.R
  {
    element: 'div[sqs_id=code_zone]',
    popover: {
	    className: 'right_tabs_ul_popover',
	    title: 'Code &rarr; server.R<p class="info_step_number">17/21</p>',
	    description: '<p>This is how you define the server part of your app.</p> \
	    <p>It contains your app logic and provides reactivity between changes in the user \
	    inputs and the app outputs.</p>',
	    position: 'left'
    },
    onNext: () => {
	    driver.preventMove();
	    $( '#code_tabs li:nth-child(3) a:first' ).click();
	    driver.moveNext();
    },
    onPrevious: () => {
	    driver.preventMove();
	    $( '#code_tabs li:nth-child(1) a:first' ).click();
	    driver.movePrevious();
    }
  },
  // 19 Code - module.R
  {
    element: '#code_tabs',
    popover: {
	    className: 'right_tabs_ul_popover',
	    title: 'Code &rarr; module.R<p class="info_step_number">18/21</p>',
	    description: '<p>Modules are a great way to manage Shiny Apps that are getting increasingly bigger and more complex.</p> \
     <p>Besides the possibility to set up a complete Shiny app, this addin also helps to extend an already \
     existing app with modules.</p> \
     <p>To create a module select <code>tagList</code> as page type.</p> \
     <p>For more informations about modules visit \
     <a href="https://Shiny.rstudio.com/articles/modules.html" target="_blank">https://Shiny.rstudio.com/articles/modules.html</a></p>',
	    position: 'left'
    },
    onNext: () => {
	    driver.preventMove();
	    $( '#right_tabs li:nth-child(3) a:first' ).click();
	    driver.moveNext();
    },
    onPrevious: () => {
	    driver.preventMove();
	    $( '#code_tabs li:nth-child(2) a:first' ).click();
	    driver.movePrevious();
    }
  },
  // 20 Export.
  {
    element: '#right_tabs',
    popover: {
	    className: 'right_tabs_popover',
	    title: 'Export<p class="info_step_number">19/21</p>',
	    description: '<p>Finally, when you are satisfied with your created Shiny app, you can export it in this tab.</p>',
	    position: 'left'
    },
    onNext: () => {
	    driver.preventMove();
	    $( '#export_tabs li:nth-child(1) a:first' ).click();
	    driver.moveNext();
    },
    onPrevious: () => {
	    driver.preventMove();
	    $( '#right_tabs li:nth-child(2) a:first' ).click();
	    $( '#code_tabs li:nth-child(3) a:first' ).click();
	    driver.movePrevious();
    }
  },
  // 21 Export - Folders.
  {
    element: '#export_tabs',
    popover: {
  	  className: 'right_tabs_ul_popover',
  	  title: 'Export &rarr; Folders<p class="info_step_number">20/21</p>',
	    description: '<p>If you haven\'t created a folder structure for your project yet, one can be created quickly here.</p>',
	    position: 'left'
    },
    onNext: () => {
	    driver.preventMove();
	    $( '#export_tabs li:nth-child(2) a:first' ).click();
	    driver.moveNext();
    }
  },
  // 22 Export - Code.
  {
    element: 'div[sqs_id=export_zone]',
    popover: {
    	className: 'right_tabs_ul_popover',
	    title: 'Export &rarr; Code<p class="info_step_number">21/21</p>',
	    description: '<p>The generated code can be exported here.</p>',
	    position: 'left'
    },
    onPrevious: () => {
	    driver.preventMove();
	    $( '#export_tabs li:nth-child(1) a:first' ).click();
	    driver.movePrevious();
    }
  },
];

  return(steps);

}