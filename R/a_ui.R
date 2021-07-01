.shiny_quick_builder_ui <- function() {
  
  ui <- fluidPage(
    title = "ShinyQuickStarter",

    # Quick fixes for lazy loaded resources from other packages.
    div(
      style = "display:none",
      icon("files-o"),
      icon("bars"),
      dateInput(inputId = "sqs_zzz1", label = "z"),
      sliderInput(inputId = "sqs_zzz2", label = "z", min = 0, max = 100, value = 50),
      switchInput(inputId = "sqs_zzz3"),
      prettyCheckbox(inputId = "sqs_zzz4", label = NULL),
      awesomeCheckbox(inputId = "sqs_zzz5", label = NULL),
      actionBttn(inputId = "sqs_zzz6", label = NULL),
      knobInput(inputId = "sqs_zzz7", label = NULL, value = 50),
      dataTableOutput("sqs_zzz8"),
      plotlyOutput("sqs_zzz9"),
      airDatepickerInput(inputId = "sqs_zzz10"),
      currencyInput(inputId = 'sqs_zzz_11', label= "z", value = 0),
      spectrumInput(inputId = 'sqs_zzz_12', label = 'z', choices = c('black')),
      fixedPage(),
      fillPage(),
      bootstrapPage(),
      navbarPage(title = ""),
      dashboardPage(dashboardHeader(), dashboardSidebar(), dashboardBody()),
      dropdown(),
      dropdownButton(),
      miniPage(
        gadgetTitleBar(
          miniTitleBarButton(inputId = 'sqs_zzz_13', label = 'Done'),
          miniTitleBarCancelButton(inputId = 'sqs_zzz_14', label = 'Cancel')
        ),
        miniTabstripPanel(miniTabPanel(title = 'title',miniContentPanel()))
      )
    ),
    
    class = "fullscreen",
    useShinyjs(),
    useShinyalert(),

    tags$head(
      tags$link(rel = "icon", href = "data:;base64,="),
      tags$style(id = "style_changer", type = "text/css")
    ),

    # Fonts.
    includeCSS(system.file("extdata/www/fonts/fonts.css", package = "ShinyQuickStarter")),

    # JQuery EasyUI.
    includeCSS(system.file("extdata/www/jquery-easyui-1.9.10/themes/gray/easyui.css", package = "ShinyQuickStarter")),
    includeScript(system.file("extdata/www/jquery-easyui-1.9.10/jquery.easyui.min.js", package = "ShinyQuickStarter")),

    # JQuery UI.
    includeScript(system.file("extdata/www/jquery-ui-1.12.1.custom/jquery-ui.min.js", package = "ShinyQuickStarter")),

    # Driver.
    includeCSS(system.file("extdata/www/driver.js-master/driver.min.css", package = "ShinyQuickStarter")),
    includeScript(system.file("extdata/www/driver.js-master/driver.min.js", package = "ShinyQuickStarter")),

    # Custom.
    includeScript(system.file("extdata/www/custom/tour_steps.js", package = "ShinyQuickStarter")),
    includeCSS(system.file("extdata/www/custom/custom.css", package = "ShinyQuickStarter")),
    includeCSS(system.file("extdata/www/custom/loader.css", package = "ShinyQuickStarter")),
    includeScript(system.file("extdata/www/custom/functions.js", package = "ShinyQuickStarter")),
    includeScript(system.file("extdata/www/custom/custom.js", package = "ShinyQuickStarter")),

    # Stop Addin.
    div(
      class = "stop_addin_button",
      actionButton(
        inputId = "stop_addin_button",
        label = HTML("&times;")
      )
    ),


    # Layout.
    div(
      id = "layout",
      class = "easyui-layout",
      style = "width:100%;height:100vh;",
      "data-options" = "fit:true",

      # West Panel.
      div(
        "data-options" = "region:'west',split:true",
        style = "width:17%",

        # Files & UI Elements.
        div(
          class = "easyui-layout",
          "data-options" = "fit:true",

          # Navigation.
          div(
            sqs_id = "navigation",
            "data-options" = "region:'north',title:'Navigation',split:true,
            collapsible:true,hideCollapsedContent:false",
            style = "height:50%",
            
            div(
              id = "info_sqs_page_type",
              
              pickerInput(
                inputId = "sqs_page_type",
                label = "Page Type",
                choices = "fluidPage",
                width = "100%"
              )
            ),

            div(
              id = "context_menu_navigation_tree",
              class = "easyui-menu",
              style = "width:120px",
              
              div(
                "Add Navigation",
                class = "add_menu",
                div(
                  div("navbarMenu", class = "add_navigation"),
                  div("navlistPanel", class = "add_navigation"),
                  div("tabsetPanel", class = "add_navigation"),
                  div("tabBox", class = "add_navigation"),
                  div("tabPanel", class = "add_navigation"),

                  div("menuItem", class = "add_navigation"),
                  div("menuSubItem", class = "add_navigation"),

                  div("sidebarSearchForm", class = "add_navigation"),
                  div("sidebarMenu", class = "add_navigation"),

                  div("tabItem", class = "add_navigation"),

                  div("dropdownMenu", class = "add_navigation"),
                  div("notificationItem", class = "add_navigation"),
                  div("messageItem", class = "add_navigation"),
                  div("taskItem", class = "add_navigation"),
                  
                  div("miniTitleBar", class = "add_navigation"),
                  div("gadgetTitleBar", class = "add_navigation"),
                  div("miniTitleBarButton", class = "add_navigation"),
                  div("miniTitleBarCancelButton", class = "add_navigation"),
                  div("miniTitleBarCancelButton", class = "add_navigation"),
                  
                  div("miniTabstripPanel", class = "add_navigation"),
                  div("miniTabPanel", class = "add_navigation"),
                  div("miniContentPanel", class = "add_navigation"),
                  div("miniButtonBlock", class = "add_navigation"),
                )
              ),
              div("Remove Element", class = "remove_navigation")
            ),

            div(
              id = "info_navigation_tree",

              tags$table(
                id = "navigation_tree",
                width = "100%"
              )
            )
          ),

          # UI Elements.
          div(
            "data-options" = "region:'center',title:'UI Elements',split:true,
            collapsible:true,hideCollapsedContent:false",
            style = "height:50%",

            div(
              sqs_id = "ui_element_zone",
              class = "easyui-accordion",
              "data-options" = "border:false,fit:true",

              div(
                id = "sqs_search_box",
                "data-options" = "collapsed:false,collapsible:false",
                
                HTML('<div class="btn-group" style="width:100%">
                        <input id="search_box" class="form-control" type="search" placeholder="Search UI Element">
                        <span id="search_clear" class="fas fa-window-close" style="display:none"></span>
                      </div>')
              ),

              div(
                id = "UI_Layout",
                title = "UI Layout",
                "data-options" = "selected:true"
              ),
              div(
                id = "UI_Inputs",
                title = "UI Inputs"
              ),
              div(
                id = "UI_Outputs",
                title = "UI Outputs"
              )
            )
          )
        )
      ),

      # Center Panel.
      # Droparea.
      div(
        sqs_id = "drop_area",
        "data-options" = "region:'center',title:'Droparea'",

        div(
          sqs_id = "drop_zone_menu",
          class = "panel_header_2",

          tags$a(
            id = "info",
            tags$i(class = "fas fa-info-circle", 
                   style = "font-size:23px;margin:0px 5px")
          ),

          div(
            id = "edit_mode_panel",
            switchInput(
              inputId = "edit_mode",
              label = "Mode",
              value = TRUE,
              onLabel = "Edit",
              offLabel = "Display",
              onStatus = "primary",
              offStatus = "danger",
              size = "mini",
              labelWidth = "auto",
              handleWidth = "auto",
              inline = TRUE
            )
          ),
          
          uiOutput(
            outputId = "validation_errors",
            style = "margin-left: 50px;
            margin-top: 5px;
            color: red;"
          ),

          div(
            class = "sqs_logo",
            "ShinyQuickStarter"
          )
        ),

        div(
          class = "drop_zone_step_1 drop_zone_step_2 drop_zone_step_3 drop_zone_step_4",
          div(
            sqs_id = "drop_zone",
            div(
              class = "loading_foreground",
              style = "display:none",
              div(
                class = "loading_animation",
                style = "color:#3c8dbc"
              )
            ),
            div(
              sqs_id = "drop_zone_content"
            )
          )
        )
      ),

      # East Panel.
      # Options & Code.
      div(
        "data-options" = "region:'east',split:true",
        style = "width:30%",

        div(
          id = "right_tabs",
          class = "easyui-tabs",
          "data-options" = "border:false,plain:true,fit:true",

          # Options.
          div(
            sqs_id = "option_zone",
            title = "Options",

            div(
              id = "options_tabs",
              class = "easyui-tabs option_tabs_step_1 option_tabs_step_2",
              "data-options" = "border:false,plain:true,fit:true",
              style = "width:100%",

              div(
                title = "UI",
                uiOutput("ui_options")
              ),
              div(
                title = "Server",
                uiOutput("server_options")
              )
            )
          ),

          # Code.
          div(
            sqs_id = "code_zone",
            title = "Code",

            div(
              id = "code_tabs",
              class = "easyui-tabs code_tabs_step_1 code_tabs_step_2 code_tabs_step_3",
              "data-options" = "border:false,plain:true,fit:true",
              style = "width:100%",

              div(
                title = "ui.R",
                uiOutput("ui_code")
              ),
              div(
                title = "server.R",
                uiOutput("server_code")
              ),
              div(
                title = "module.R",
                uiOutput("module_code")
              )
            )
          ),

          div(
            sqs_id = "export_zone",
            title = "Export",

            div(
              id = "export_tabs",
              class = "easyui-tabs export_tabs_step_1 export_tabs_step_2",
              "data-options" = "border:false,plain:true,fit:true",
              style = "width:100%",

              div(
                sqs_id = "export_tabs_folders",
                title = "Folders",

                shinyDirButton(
                  id = "export_folders_directory",
                  label = "Directory",
                  title = "Directory",
                  buttonType = "default",
                  style = "display:inline"
                ),

                checkboxInput(
                  inputId = "create_sub_folder",
                  label = "Create sub folder?",
                  value = FALSE
                ),

                conditionalPanel(
                  condition = "input.create_sub_folder",

                  textInput(
                    inputId = "sub_folder_name",
                    label = "Sub folder",
                    value = "app",
                    placeholder = "app"
                  )
                ),

                uiOutput("export_folders_directory"),

                checkboxInput(
                  inputId = "create_as_rstudio_project",
                  label = "Create as RStudio project?",
                  value = TRUE
                ),

                conditionalPanel(
                  condition = "input.create_as_rstudio_project",

                  textInput(
                    inputId = "project_name",
                    label = "Project name",
                    value = "app",
                    placeholder = "app"
                  )
                ),

                checkboxGroupInput(
                  inputId = "create_folders",
                  label = "Create folders for:",
                  choices = c("data", "functions", "modules", "www"),
                  selected = c("data", "functions", "modules", "www")
                ),

                actionButton(
                  inputId = "export_folders",
                  label = "Export Folders"
                )
              ),

              div(
                sqs_id = "export_tabs_code",
                title = "Code",

                shinyDirButton(
                  id = "export_code_directory",
                  label = "Directory",
                  title = "Directory",
                  buttonType = "default",
                  style = "display:inline"
                ),

                uiOutput("export_code_directory"),
                
                checkboxInput(
                  inputId = "single_quotes",
                  label = "Use single quotes?",
                  value = FALSE
                ),

                conditionalPanel(
                  condition = "input.sqs_page_type != 'tagList'",
                  
                  checkboxInput(
                    inputId = "multiple_files",
                    label = "Multiple files (global.R, ui.R, server.R)?",
                    value = TRUE
                  ),

                  conditionalPanel(
                    condition = "!input.multiple_files",

                    textInput(
                      inputId = "app_filename",
                      label = "Filename",
                      value = "app.R",
                      placeholder = "app.R"
                    )
                  ),

                  tags$p(tags$b("Options for global.R")),

                  checkboxInput(
                    inputId = "add_documentation",
                    label = "Add documentation block?",
                    value = TRUE
                  ),
                  checkboxInput(
                    inputId = "remove_all",
                    label = "Clear objects from workspace before app start?",
                    value = TRUE
                  ),
                  checkboxInput(
                    inputId = "source_functions",
                    label = "Source functions in 'functions' folder?",
                    value = TRUE
                  ),
                  checkboxInput(
                    inputId = "source_modules",
                    label = "Source modules in 'modules' folder?",
                    value = TRUE
                  )
                ),

                conditionalPanel(
                  condition = "input.sqs_page_type == 'tagList'",

                  textInput(
                    inputId = "module_name",
                    label = "Module name",
                    value = "module",
                    placeholder = "module"
                  ),

                  selectInput(
                    inputId = "module_suffix",
                    label = "Module suffix",
                    choices = c("_ui/_server", "UI/Server")
                  )
                ),

                actionButton(
                  inputId = "export_code",
                  label = "Export Code"
                )
              )
            )
          )
        )
      )
    )
  )

  return(ui)
  
}
