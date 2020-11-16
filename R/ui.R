##
##
.shiny_quick_starter_ui <- miniPage(

  #### Header. ####

  # Fix for "shinyjs is not defined".
  uiOutput("package_import"),

  includeCSS("inst/extdata/www/custom.css"),
  includeScript("inst/extdata/www/custom.js"),

  gadgetTitleBar(
    title = span(
      strong("ShinyQuickStarter"),
      span("by",
           a(href='https://www.th-deg.de/en/research/technology-campuses/tc-grafenau',
             "TC Grafenau", target="_blank")
      )
    ),
    left = miniTitleBarCancelButton(
      inputId = "button_cancel",
      label = "Cancel"
    ),
    right = miniTitleBarButton(
      inputId = "button_export_settings",
      label = "Export Settings",
      primary = TRUE
    )
  ),


  #### Content. ####


  miniTabstripPanel(


    #### Step 1: Project Structure. ####


    miniTabPanel(
      title = "Step 1: Project Structure",
      icon = icon("folder-open"),

      miniContentPanel(
        fluidRow(
          column(
            width = 3,

            h3("Settings"),

            textInput(
              inputId = "text_project_name",
              label = "Project name",
              value = "project"
            ),
            textOutput("validate_text_project_name"),

            checkboxInput(
              inputId = "checkbox_create_in_current_directory",
              label = "Create in current directory",
              value = TRUE
            ),

            conditionalPanel(
              condition = "!input.checkbox_create_in_current_directory",

              shinyDirButton("button_directory", "Choose Project Folder", "Please select a folder")
            ),

            checkboxInput(
              inputId = "checkbox_create_project_folder",
              label = "Create sub-folder for the Project",
              value = TRUE
            ),

            conditionalPanel(
              condition = "output.check_import_sensible",

              p(actionButton(
                inputId = "button_import_settings",
                label = "Import settings",
                class = "btn-primary")
              )
            ),

            br(),

            checkboxInput(
              inputId = "checkbox_rstudio_project",
              label = "Create as RStudio Project",
              value = TRUE
            ),

            checkboxInput(
              inputId = "checkbox_multiple_files",
              label = "Multiple Files (global.R, ui.R, server.R)",
              value = TRUE
            ),

            checkboxInput(
              inputId = "checkbox_modules",
              label = "Modules",
              value = TRUE
            ),

            checkboxInput(
              inputId = "checkbox_custom_css_js",
              label = "Custom CSS/JS Files",
              value = FALSE
            ),

            tags$br(),

            verbatimTextOutput("check"),

            conditionalPanel(
              condition = "output.check_create_possible",

              p(actionButton(
                inputId = "button_create_project_structure",
                label = "Create Project Structure",
                class = "btn-primary")
              )
            ),

            conditionalPanel(
              condition = "output.check_update_possible",

              p(actionButton(
                inputId = "button_update_project_structure",
                label = "Update Project Structure",
                class = "btn-primary")
              )
            ),

            conditionalPanel(
              condition = "output.check_delete_possible",

              p(actionButton(
                inputId = "button_delete_project_structure",
                label = "Delete Project Structure",
                class = "btn-primary")
              )
            )

          ),

          column(
            width = 9,

            h3("Project Structure"),
            htmlOutput("directory_path"),
            htmlOutput("project_structure"),
            htmlOutput("project_structure_created"),
            htmlOutput("project_settings_imported")
          )
        )
      )
    ),


    #### Step 2: Files. ####


    miniTabPanel(
      title = "Step 2: Files",
      icon = icon("copy"),

      miniContentPanel(
        fluidRow(
          column(
            width = 3,

            h3("Settings"),

            # Framework & Navigation.
            h3("Framework & Navigation"),

            selectInput(
              inputId = "select_framework",
              label = "Framework",
              choices = c("Shiny + ShinyDashboard")#, "Shiny")
            ),
            selectInput(
              inputId = "select_navigation_type",
              label = "Navigation",
              choices = c("Sidebar")
            ),
            tags$br(),

            # Design.
            h3("Design"),

            textInput(
              inputId = "text_title",
              label = "Title",
              value = "Dashboard"
            ),

            checkboxInput(
              inputId = "checkbox_logo",
              label = "Logo",
              value = FALSE
            ),

            conditionalPanel(
              condition = "input.checkbox_logo",

              fileInput(
                inputId = "file_image_upload",
                label = "Upload a logo",
                accept = c("image/*")
              ),

              imageOutput("logo_image", width=NULL, height=NULL)
            ),

            conditionalPanel(
              condition = "input.select_framework == 'Shiny + ShinyDashboard'",

              selectInput(
                inputId = "select_skin",
                label = "Skin",
                choices = list("blue", "black", "purple", "green", "red", "yellow", "custom"),
                selected = "blue"
              ),

              conditionalPanel(
                condition = "input.select_skin == 'custom'",

                colourInput(
                  inputId = "colour_custom_skin",
                  label = "Custom Colour",
                  value = "blue"
                )
              )
            ),
            conditionalPanel(
              condition = "input.select_framework == 'Shiny'",

              selectInput(
                inputId = "select_theme",
                label = "Theme",
                choices = list("cerulean", "cosmo", "cyborg", "darkly", "flatly", "journal",
                               "lumen", "paper", "readable", "sandstone", "simplex", "slate",
                               "spacelab", "superhero", "unites", "yeti")
              )
            ),
            tags$br(),

            h3("Global Code"),

            checkboxInput(
              inputId = "checkbox_remove_variables",
              label = "Removing all Variables at App-Start",
              value = TRUE
            ),

            checkboxInput(
              inputId = "checkbox_source_functions",
              label = "Source Functions",
              value = TRUE
            ),

            conditionalPanel(
              condition = "input.checkbox_modules",

              checkboxInput(
                inputId = "checkbox_source_modules",
                label = "Source Modules",
                value = TRUE
              )
            ),

            checkboxInput(
              inputId = "checkbox_load_data",
              label = "Load Data",
              value = TRUE
            )
          ),

          column(
            width = 9,

            selectInput(
              inputId = "select_filename_1",
              label = "File",
              choices = c("global.R", "ui.R", "server.R")
            ),
            tags$br(),
            withSpinner(
              htmlOutput("code_ui_basic"),
              type = 6
            )
          )
        )
      )
    ),


    #### Step 3: Navigation. ####


    miniTabPanel(
      title = "Step 3: Navigation",
      icon = icon("map"),

      miniContentPanel(
        fluidRow(
          column(
            width = 12,
            
            column(
              width = 3,
            
              hidden(
                actionButton(
                  inputId = "button_go_to_previous",
                  label = "Previous",
                  class = "btn-primary"
                ) 
              ),
              actionButton(
                inputId = "button_go_to_next",
                label = "Next",
                class = "btn-primary"
              )
            ),
            
            column(
              width = 9,
  
              radioGroupButtons(
                inputId = "button_menue",
                choices = c("Navigation", "Modules", "Navigation + Modules", "Overview", "Code Export")
              )
            )
          )
        ),
        
        fluidRow(
          column(
            width = 12,

            #### Step 3.1: Navigation. ####

            conditionalPanel(
              condition = "input.button_menue == 'Navigation'",

              column(
                width = 3,
                
                htmlOutput("h3_navigation"),

                textInput(
                  inputId = "navigation_position",
                  label = "Navigation-Position",
                  placeholder = "e. g. 1 or 1.1",
                ),
                textInput(
                  inputId = "navigation_title",
                  label = "Title"
                ),
                textInput(
                  inputId = "navigation_id",
                  label = "Navigation-ID"
                ),

                hidden(
                  verbatimTextOutput("navigation_form_mode")
                ),

                conditionalPanel(
                  condition = "output.navigation_form_mode == 'add'",

                  actionButton(
                    inputId = "button_navigation_add",
                    label = "Add row"
                  ),
                  htmlOutput("validate_navigation_add")
                ),

                conditionalPanel(
                  condition = "output.navigation_form_mode == 'edit'",

                  actionButton(
                    inputId = "button_navigation_edit",
                    label = "Edit row"
                  ),
                  htmlOutput("validate_navigation_edit")
                )
              ),

              column(
                width = 9,

                actionButton(
                  inputId = "button_navigation_add_form",
                  label = "",
                  icon = icon("plus", "fa-0.5x")
                ),
                actionButton(
                  inputId = "button_navigation_delete_all",
                  label = "Delete all rows",
                  icon = icon("thrash", "fa-0.5x")
                ),
                htmlOutput("navigation_errors"),
                DTOutput("table_navigation")
              )
            ),


            #### Step 3.2: Module. ####


            conditionalPanel(
              condition = "input.checkbox_modules",

              conditionalPanel(
                condition = "input.button_menue == 'Modules'",

                column(
                  width = 3,

                  htmlOutput("h3_module"),

                  h4("Global Setting"),

                  selectInput(
                    inputId = "select_suffix_style",
                    label = "Suffix-Stlye",
                    choices = c("_ui/_server", "UI/Server")
                  ),

                  br(),

                  h4("Module Settings"),

                  textInput(
                    inputId = "module_id",
                    label = "Module-ID"
                  ),
                  checkboxInput(
                    inputId = "module_return",
                    label = "Return"
                  ),

                  hidden(
                    verbatimTextOutput("module_form_mode")
                  ),

                  conditionalPanel(
                    condition = "output.module_form_mode == 'add'",

                    actionButton(
                      inputId = "button_module_add",
                      label = "Add row"
                    ),
                    htmlOutput("validate_module_add")
                  ),

                  conditionalPanel(
                    condition = "output.module_form_mode == 'edit'",

                    actionButton(
                      inputId = "button_module_edit",
                      label = "Edit row"
                    ),
                    htmlOutput("validate_module_edit")
                  )
                ),

                column(
                  width = 9,

                  actionButton(
                    inputId = "button_module_add_form",
                    label = "",
                    icon = icon("plus", "fa-0.5x")
                  ),
                  actionButton(
                    inputId = "button_module_delete_all",
                    label = "Delete all rows",
                    icon = icon("thrash", "fa-0.5x")
                  ),
                  DTOutput("table_module")
                )
              )
            ),


            #### Step 3.3: Navigation + Modules. ####

            conditionalPanel(
              condition = "input.checkbox_modules",

              conditionalPanel(
                condition = "input.button_menue == 'Navigation + Modules'",

                column(
                  width = 3,

                  htmlOutput("h3_navigation_module"),

                  div(id = "div"),

                  selectInput(
                    inputId = "navigation_module_navigation_id",
                    label = "Navigation-ID",
                    choices = c()
                  ),
                  selectInput(
                    inputId = "navigation_module_module_id",
                    label = "Module-ID",
                    choices = c()
                  ),
                  textInput(
                    inputId = "navigation_module_instance_id",
                    label = "Module-Instance-ID"
                  ),

                  hidden(
                    verbatimTextOutput("navigation_module_form_mode")
                  ),

                  conditionalPanel(
                    condition = "output.navigation_module_form_mode == 'add'",

                    actionButton(
                      inputId = "button_navigation_module_add",
                      label = "Add row"
                    ),
                    htmlOutput("validate_navigation_module_add")
                  ),

                  conditionalPanel(
                    condition = "output.navigation_module_form_mode == 'edit'",

                    actionButton(
                      inputId = "button_navigation_module_edit",
                      label = "Edit row"
                    ),
                    htmlOutput("validate_navigation_module_edit")
                  )
                ),

                column(
                  width = 9,

                  actionButton(
                    inputId = "button_navigation_module_add_form",
                    label = "",
                    icon = icon("plus", "fa-0.5x")
                  ),
                  actionButton(
                    inputId = "button_navigation_module_delete_all",
                    label = "Delete all rows",
                    icon = icon("thrash", "fa-0.5x")
                  ),
                  DTOutput("table_navigation_module")
                )
              )
            ),


            #### Step 3.4: Overview. ####


            conditionalPanel(
              condition = "input.button_menue == 'Overview'",
              
              column(
                width = 12,
                
                h3("Overview"),
                column(
                  width = 1
                ),
                column(
                  width = 10,
                  tags$pre(
                    visNetworkOutput("app_structure", height="750px")
                  )
                )
              )
            ),


            #### Step 3.5: Code. ####

            conditionalPanel(
              condition = "input.button_menue == 'Code Export'",

              column(
                width = 3,

                h3("Code"),

                selectInput(
                  inputId = "select_filename_2",
                  label = "File",
                  choices = c("global.R", "ui.R", "server.R")
                ),

                actionButton(
                  inputId = "button_save_code",
                  label = "Export all code",
                  class = "btn-primary"
                )
              ),

              column(
                width = 9,

                withSpinner(
                  htmlOutput("code_ui_modules"),
                  type = 6
                )
              )
            )
          )
        )
      )
    )
  )

)
