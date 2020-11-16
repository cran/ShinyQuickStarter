##
##
.shiny_quick_starter_server <- function(input, output, session) {


  #### Settings as reactive values. ####


  values <- reactiveValues(
    navigation = navigation,
    module = module,
    navigation_module = navigation_module,

    hidden_navigation_id = nrow(navigation),
    hidden_module_id = nrow(module),
    hidden_navigation_module_id = nrow(navigation_module),

    navigation_form_mode = "add",
    module_form_mode = "add",
    navigation_module_form_mode = "add",

    navigation_edit_index = -1,
    module_edit_index = -1,
    navigation_module_edit_index = -1
  )

  input_fields <- reactive({
    x = reactiveValuesToList(input)
    x = x[!str_detect(names(x), "table_")]
    x = x[!str_detect(names(x), "button_")]
    x = x[!startsWith(names(x), "navigation_")]
    x = x[!startsWith(names(x), "module_")]
    x = x[!(names(x) %in% c("select_filename_1", "select_filename_2", "select_navigation", "select_module",
                            "checkbox_create_in_current_directory", "checkbox_create_project_folder"))]
    x
  })


  #### Basic Setup at Addin start. ####


  output$package_import <- renderUI({
    tagList(
      useShinyjs(),
      useShinyalert()
    )
  })


  volumes <- c(Home = path_home(), "R Installation" = R.home(), getVolumes()())
  shinyDirChoose(
    input,
    id = "button_directory",
    roots = volumes,
    session = session,
    restrictions = system.file(package = "base")
  )



  #### Header. ####



  # Close App when tab or browser is closed.
  session$onSessionEnded(function() {
    stopApp()
  })


  observeEvent(input$button_cancel, {
    invisible(stopApp())
  })
  
  
  observeEvent(input$button_export_settings, {
    validate(
      .check_navigation_position(values$navigation)
    )
    
    if (!.check_project_options(paths())[["delete_possible"]]) {
      showNotification("Export of settings unsucessful.\n
                       Project Structure needs to be created beforehand.",
                       type = "error")
    } else {
      paths_in_directory = c(".ShinyQuickStarter/settings.txt",
                             ".ShinyQuickStarter/navigation.RDS",
                             ".ShinyQuickStarter/module.RDS",
                             ".ShinyQuickStarter/navigation_module.RDS")
      if (input$checkbox_create_project_folder) {
        paths_in_directory = paste(basename(paths()[["project"]]), paths_in_directory, sep="/")      
      }
      
      text_1 = paste0("<p><b>", 4, "</b> files within the following directory will be created or updated.</p>")
      text_2 = paste0("<pre style='text-align: left'>", 
                      paths()[["directory"]], 
                      "</pre>")
      text_3 = paste0("<pre style='text-align: left; height: 300px; overflow: auto;'>",
                      paste(paths_in_directory, collapse="<br>"),
                      "</pre>")
      
      text = paste(text_1, text_2, text_3, sep="<br>")
      
      shinyalert(
        inputId = "button_export_settings_2",
        title = "Warning",
        text = text,
        type = "warning",
        closeOnEsc = TRUE,
        closeOnClickOutside = TRUE,
        html = TRUE,
        showConfirmButton = TRUE,
        showCancelButton = TRUE,
        confirmButtonText = "Export settings",
        cancelButtonText = "Cancel",
        size = "m",
        animation = TRUE,
        className = "shinyalert-with-scrollbar"
      )
    }
  })


  observeEvent(input$button_export_settings_2, {
    if (input$button_export_settings_2) {
      if (!.check_project_options(paths())[["delete_possible"]]) {
        showNotification("Export of settings unsucessful.\n
                       Project Structure needs to be created beforehand.",
                         type = "error")
      } else {
        .export_settings(paths(), input_fields(),
                         values$navigation, values$module, values$navigation_module)
        showNotification("Exported settings.", type="message")
      } 
    }
  })



  #### Step 1: Project Structure. ####


  validate_directory_path <- reactive({
    validate(
      need(paths()[["directory"]] != "", "Please select a valid directory.")
    )
  })


  output$directory_path <- renderText({
    validate_directory_path()

    paste0("<pre>", paths()[["directory"]], "</pre>")
  })


  paths <- reactive({
    .get_paths(
      input$checkbox_create_in_current_directory,
      parseDirPath(volumes, input$button_directory),
      input$checkbox_create_project_folder,
      input$text_project_name,
      input$checkbox_rstudio_project,
      input$checkbox_modules,
      input$checkbox_multiple_files,
      input$checkbox_custom_css_js
    )
  })


  observeEvent({
    input$button_create_project_structure
    input$button_update_project_structure_2
    input$button_delete_project_structure_2
    input$button_import_settings
    input$button_export_settings
    paths()
    input_fields()
    values$navigation
    values$module
    values$navigation_module
  }, {

    validate_directory_path()

    # Determines what project structure buttons are displayed.
    options = .check_project_options(paths(), input_fields(), input$checkbox_create_project_folder,
                                     values$navigation, values$module, values$navigation_module)

    output$check_create_possible <- reactive({ options[["create_possible"]] })
    outputOptions(output, 'check_create_possible', suspendWhenHidden=FALSE)

    output$check_update_possible <- reactive({ options[["update_possible"]] })
    outputOptions(output, 'check_update_possible', suspendWhenHidden=FALSE)

    output$check_delete_possible <- reactive({ options[["delete_possible"]] })
    outputOptions(output, 'check_delete_possible', suspendWhenHidden=FALSE)

    output$check_import_sensible <- reactive({
      all(options[["delete_possible"]], options[["import_possible"]], !options[["settings_matching"]])
    })
    outputOptions(output, 'check_import_sensible', suspendWhenHidden=FALSE)


    # Updates for the information tags.
    output$project_structure_created <- renderText({
      text = ""

      if (options[["delete_possible"]]) {
        if (options[["update_possible"]]) {
          text = paste("<pre style='background-color: #f7af89'>", "Project Structure needs to be updated.", "</pre>")
        } else {
          text = paste("<pre style='background-color: #90EE90'>", "Project Structure successfully setup.", "</pre>")
        }
      } else {
        text = paste("<pre style='background-color: #FF6347'>", "Project Structure not setup yet.", "</pre>")
      }
      return(text)
    })

    output$project_settings_imported <- renderText({
      text = ""

      if (options[["delete_possible"]]) {
        if (options[["import_possible"]]) {
          if (options[["settings_matching"]]) {
            text = paste("<pre style='background-color: #90EE90'>", "Match between current and saved Project Settings.", "</pre>")
          } else {
            text = paste("<pre style='background-color: #FF6347'>", "Project Settings different to current settings.",
                         "Import your saved settings if you want to resume working with them.</pre>")
          }
        } else {
          text = paste("<pre style='background-color: #f7af89'>", "Export your Project Settings regularly to avoid losing any progress.</pre>")
        }
      }
      return(text)
    })

  }, priority = -1)


  validate_text_project_name <- reactive({
    validate(
      need(input$text_project_name != "", "Project name missing.")
    )
  })

  output$validate_text_project_name <- renderText({
    if (input$checkbox_create_project_folder | input$checkbox_rstudio_project) {
      validate_text_project_name()
    }
  })


  output$project_structure <- renderText({
    paste0("<pre>", paste(paths()[["short"]], collapse="\n"), "</pre>")
  })
  
  
  observeEvent(input$button_create_project_structure, {
    validate_text_project_name()
    validate_directory_path()

    text_1 = paste0("<p><b>", 
                    length(paths()[["full"]]), 
                    "</b> files within the following directory will be created.</p>")
    text_2 = paste0("<pre style='text-align: left'>", 
                    paths()[["directory"]], 
                    "</pre>")
    text_3 = paste0("<pre style='text-align: left; height: 200px; overflow: auto;'>",
                    paste(paths()[["short"]], collapse="<br>"),
                    "</pre>")
    
    text = paste(text_1, text_2, text_3, sep="<br>")
    
    shinyalert(
      inputId = "button_create_project_structure_2",
      title = "Warning",
      text = text,
      type = "warning",
      closeOnEsc = TRUE,
      closeOnClickOutside = TRUE,
      html = TRUE,
      showConfirmButton = TRUE,
      showCancelButton = TRUE,
      confirmButtonText = "Create Project Structure",
      cancelButtonText = "Cancel",
      size = "m",
      animation = TRUE,
      className = "shinyalert-with-scrollbar"
    )
  })


  observeEvent(input$button_create_project_structure_2, {
    if (input$button_create_project_structure_2) {
      validate_text_project_name()
      validate_directory_path()
      
      .create_folder_structure(paths())
      showNotification("Created Project Structure.", type="message") 
    }
  })


  observeEvent(input$button_update_project_structure, {
    validate_text_project_name()
    validate_directory_path()

    options = .check_project_options(paths(), input_fields(), input$checkbox_create_project_folder,
                                     values$navigation, values$module, values$navigation_module)

    text_1 = paste0("<p><b>", 
                    length(options[["update_delete"]]), 
                    "</b> files within the project directory will be deleted.</p>")
    text_2 = paste0("<pre style='text-align: left; height: 100px; overflow: auto;'>",
                    paste(options[["update_delete"]], collapse="<br>"),
                    "</pre>")
    text_3 = paste0("<p><b>", 
                    length(options[["update_create"]]), 
                    "</b> files within the project directory will be created.</p>")
    text_4 = paste0("<pre style='text-align: left; height: 100px; overflow: auto;'>",
                    paste(options[["update_create"]], collapse="<br>"),
                    "</pre>")

    text = paste(text_1, text_2, text_3, text_4, sep="<br>")

    shinyalert(
      inputId = "button_update_project_structure_2",
      title = "Warning",
      text = text,
      type = "warning",
      closeOnEsc = TRUE,
      closeOnClickOutside = TRUE,
      html = TRUE,
      showConfirmButton = TRUE,
      showCancelButton = TRUE,
      confirmButtonText = "Update Project Structure",
      cancelButtonText = "Cancel",
      size = "m",
      animation = TRUE,
      className = "shinyalert-with-scrollbar"
    )
  })


  observeEvent(input$button_update_project_structure_2, {
    if (input$button_update_project_structure_2) {
      options = .check_project_options(paths(), input_fields(), input$checkbox_create_project_folder,
                                       values$navigation, values$module, values$navigation_module)

      .update_folder_structure(paths(),
                               delete = options[["update_delete"]],
                               create = options[["update_create"]])
      showNotification("Updated Project Structure.", type="message")
    }
  })


  observeEvent(input$button_delete_project_structure, {

    paths_in_directory = list.files(paths()[["project"]], recursive=TRUE, include.dirs=TRUE, all.files=TRUE)
    if (input$checkbox_create_project_folder) {
      paths_in_directory = paste(basename(paths()[["project"]]), paths_in_directory, sep="/")      
    }

    text_1 = paste0("<p><b>", 
                    length(paths_in_directory),
                    "</b> files within the following directory will be deleted.</p>")
    text_2 = paste0("<pre style='text-align: left'>", 
                    paths()[["directory"]], 
                    "</pre>")
    text_3 = paste0("<pre style='text-align: left; height: 300px; overflow: auto;'>",
                    paste(paths_in_directory, collapse="<br>"),
                    "</pre>")

    text = paste(text_1, text_2, text_3, sep="<br>")

    shinyalert(
      inputId = "button_delete_project_structure_2",
      title = "Warning",
      text = text,
      type = "warning",
      closeOnEsc = TRUE,
      closeOnClickOutside = TRUE,
      html = TRUE,
      showConfirmButton = TRUE,
      showCancelButton = TRUE,
      confirmButtonText = "Delete Project Structure",
      cancelButtonText = "Cancel",
      size = "m",
      animation = TRUE,
      className = "shinyalert-with-scrollbar"
    )
  })


  observeEvent(input$button_delete_project_structure_2, {
    if (input$button_delete_project_structure_2) {
      .delete_folder_structure(paths()[["project"]])
      showNotification("Deleted Project Structure.", type="message")
    }
  })


  # Imports the settings in the project-folder at the start of the addin, provided they exist.
  # For flexibility the input fields get updated with the settings based on the input type which
  # is the prefix of every inputID (text_ -> textInput, select_ -> selectInput, checkbox_ ->
  # checkboxInput, colour_ -> colourInput).
  observeEvent(input$button_import_settings, {
    
    p = paths()

    if (file.exists(paste(p[["addin_data"]], "settings.txt", sep="/"))) {

      result = .import_settings(p)

      settings = result$settings
      text_settings = settings[!str_detect(settings$name, "text_"),]

      for (index in 1:nrow(text_settings)) {
        updateTextInput(
          session = session,
          inputId = text_settings$name[index],
          value = text_settings$value[index]
        )
      }

      select_settings = settings[!str_detect(settings$name, "select_"),]

      for (index in 1:nrow(select_settings)) {
        updateSelectInput(
          session = session,
          inputId = select_settings$name[index],
          selected = select_settings$value[index]
        )
      }

      checkbox_settings = settings[str_detect(settings$name, "checkbox_"),]
      #checkbox_settings = checkbox_settings[checkbox_settings$name %in% c("checkbox_create_in_current_directory", 
      #                                                                    "checkbox_create_project_folder"),]

      for (index in 1:nrow(checkbox_settings)) {
        updateCheckboxInput(
          session = session,
          inputId = checkbox_settings$name[index],
          value = as.logical(checkbox_settings$value[index])
        )
      }

      colour_settings = settings[str_detect(settings$name, "colour_"),]

      for (index in 1:nrow(colour_settings)) {
        updateColourInput(
          session = session,
          inputId = colour_settings$name[index],
          value = colour_settings$value[index]
        )
      }

      values$navigation = result$navigation
      values$module = result$module
      values$navigation_module = result$navigation_module
      
      # Fixes the missing updateSelectInput of navigation_module_navigation_id and 
      # navigation_module_module_id after settings import.
      # Replace selectInputs with new ones.
      removeUI(selector = ".shiny-input-container:has(#navigation_module_module_id)")
      insertUI(
        selector = "#div",
        where = "afterEnd",
        ui = selectInput(
          inputId = "navigation_module_module_id",
          label = "Module-ID",
          choices = result$module$Module_ID
        )
      )
      
      removeUI(selector = ".shiny-input-container:has(#navigation_module_navigation_id)")
      insertUI(
        selector = "#div",
        where = "afterEnd",
        ui = selectInput(
          inputId = "navigation_module_navigation_id",
          label = "Navigation-ID",
          choices = .get_list_for_navigation_select(result$navigation)
        )
      )

      values$hidden_navigation_id = .get_hidden_id(values$navigation$Hidden_Navigation_ID)
      values$hidden_module_id = .get_hidden_id(values$module$Hidden_Module_ID)
      values$hidden_navigation_module_id = .get_hidden_id(values$navigation_module$Hidden_Navigation_Module_ID)


      # Render logo if one was already uploaded.
      if (file.exists(paste(p[["project"]], "app/www/logo.jpg", sep="/"))) {
        output$logo_image <- renderImage({
          list(src = paste(p[["project"]], "app/www/logo.jpg", sep="/"), width = "100%")
        }, deleteFile=FALSE)
      }

      showNotification("Imported settings.", type="message")

    }

  }, priority=1)


  observeEvent(input$checkbox_modules, {

    if (input$checkbox_modules) {
      choices = c("Navigation", "Modules", "Navigation + Modules", "Overview", "Code Export")
    } else {
      choices = c("Navigation", "Overview", "Code Export")
    }

    updateRadioGroupButtons(
      session = session,
      inputId = "button_menue",
      label = "",
      choices = choices
    )

  })



  #### Step 2: Files. ####


  observeEvent(input$select_framework, {
    if (input$select_framework == "Shiny + ShinyDashboard") {
      updateSelectInput(
        session = session,
        inputId = "select_navigation_type",
        choices = c("Sidebar")
      )
    } else {
      updateSelectInput(
        session = session,
        inputId = "select_navigation_type",
        choices = c("Sidebar", "Navbar", "Sidebar + Navbar", "No Navigation")
      )
    }
  })


  observeEvent({
    input$checkbox_multiple_files
    input$checkbox_custom_css_js
  } , {

    if (input$checkbox_multiple_files) {
      choices = c("global.R", "ui.R", "server.R")
    } else {
      choices = c("app.R")
    }

    if (input$checkbox_custom_css_js) {
      choices = c(choices, "custom.css", "custom.js")
    }

    updateSelectInput(
      session = session,
      inputId = "select_filename_1",
      choices = choices
    )
    updateSelectInput(
      session = session,
      inputId = "select_filename_2",
      choices = choices
    )
  })


  output$code_ui_basic <- renderUI({
    validate(
      .check_navigation_position(values$navigation)
    )

    text = .prepare_code(input$select_filename_1, values$code)

    HTML(paste("<pre>", text, "</pre>"))

  })


  observeEvent(input$file_image_upload$datapath, {

    if (.check_project_options(paths())[["delete_possible"]]) {
      if (length(input$file_image_upload$datapath) != 0) {
        file.copy(from = input$file_image_upload$datapath,
                  to = paste(paths()[["project"]], "app/www/logo.jpg", sep="/"),
                  overwrite = TRUE,
                  copy.mode = TRUE)
      }
    }

    output$logo_image <- renderImage({
      list(src = gsub("\\\\", "/", input$file_image_upload$datapath),
           width = "100%")
    }, deleteFile=FALSE)

  })



  #### Step 3: Navigation. ####
  
  
  # User guidance.
  
  
  observeEvent(input$button_menue, {
    if (input$checkbox_modules) {
      choices = c("Navigation", "Modules", "Navigation + Modules", "Overview", "Code Export") 
    } else {
      choices = c("Navigation", "Overview", "Code Export")
    }
    selected = input$button_menue
    
    if (match(selected, choices) == 1) {
      shinyjs::hide("button_go_to_previous")
    } else {
      shinyjs::show("button_go_to_previous")    
    }
    
    if (match(selected, choices) == length(choices)) {
      shinyjs::hide("button_go_to_next")
    } else {
      shinyjs::show("button_go_to_next")
    }
  })
  
  
  observeEvent(input$button_go_to_previous, {
    if (input$checkbox_modules) {
      choices = c("Navigation", "Modules", "Navigation + Modules", "Overview", "Code Export") 
    } else {
      choices = c("Navigation", "Overview", "Code Export")
    }
    selected = input$button_menue
    
    updateRadioGroupButtons(
      session = session, 
      inputId = "button_menue",
      selected = choices[match(selected, choices) - 1]
    )

  }, priority = 1)
  
  
  observeEvent(input$button_go_to_next, {
    if (input$checkbox_modules) {
      choices = c("Navigation", "Modules", "Navigation + Modules", "Overview", "Code Export") 
    } else {
      choices = c("Navigation", "Overview", "Code Export")
    }
    selected = input$button_menue
    
    updateRadioGroupButtons(
      session = session, 
      inputId = "button_menue", 
      selected = choices[match(selected, choices) + 1]
    )

  }, priority = 1)
  
  
  #### table_navigation. ####

  
  # READ rows.


  output$table_navigation <- renderDT({
    table = values$navigation
    table$Edit = 0
    if (values$navigation_edit_index != -1) {
      table$Edit[values$navigation_edit_index] = 1 
    }
    table = .buttons_in_dt(table, "navigation", hidden_columns=c(1,5))

    if (values$navigation_form_mode == "edit") {
      table = table %>%
        formatStyle(
          columns = "Edit",
          target = "row",
          backgroundColor = styleEqual(c(1), c("#5bc0de"))
        )
    }

    table
  })


  output$navigation_errors <- renderText({
    validate(
      .check_navigation_position(values$navigation)
    )
  })


  # Determines add/edit mode for conditionalPanels.
  output$navigation_form_mode <- reactive({
    values$navigation_form_mode
  })
  outputOptions(output, 'navigation_form_mode', suspendWhenHidden=FALSE)


  # CREATE row.


  observeEvent(input$button_navigation_add_form, {
    # Empty the input fields in the form.

    values$navigation_form_mode = "add"
    values$navigation_edit_index = -1

    shinyjs::reset("navigation_position")
    shinyjs::reset("navigation_id")
    shinyjs::reset("navigation_title")
  })


  validate_navigation_add <- eventReactive(input$button_navigation_add, {
    validate(
      need(input$navigation_id != "", "ID missing."),
      need(!input$navigation_id %in% values$navigation$Navigation_ID, "ID already existing."),
      need(input$navigation_title != "", "Title missing."),
      need(input$navigation_position != "", "Position missing."),
      need(!input$navigation_position %in% values$navigation$Navigation_Position, "Position already existing."),
      need(str_detect(input$navigation_position, "^([0-9]+)(\\.[0-9]+)*$"),
           "Invalid characters in Position. Only numbers and dots as dividers are valid.")
    )
      
    paste0("<span style='color:green'><b>", input$navigation_id, "</b> sucessfully added.</span>") 
  })


  observeEvent(input$button_navigation_add, {
    output$validate_navigation_add <- renderText({
      validate_navigation_add()
    })
  }, priority = 10)
  
  
  observeEvent({
    input$button_navigation_add_form
    input$button_navigation_delete
    input$button_navigation_delete_all
    input$button_import_settings
  }, {
    output$validate_navigation_add <- renderText({""})
    output$validate_navigation_edit <- renderText({""})
  }, priority = 10)


  observeEvent(input$button_navigation_add, {
    # Insert new row in the data.table.

    validate_navigation_add()

    table = values$navigation
    values$hidden_navigation_id = values$hidden_navigation_id + 1

    new_row = data.table(
      Hidden_Navigation_ID = paste("Navigation", values$hidden_navigation_id, sep="_"),
      Navigation_Position = input$navigation_position,
      Navigation_ID = input$navigation_id,
      Title = input$navigation_title
    )

    table = rbind(table, new_row)
    position = str_replace(table$Navigation_Position, "\\.", "#")
    position = str_replace_all(position, "\\.", "")
    position = str_replace(position, "#", "\\.")
    position = as.numeric(position)
    values$navigation = table[order(position),]

  })


  # SELECT row.


  observeEvent(input$button_navigation_edit_form, {
    # Fill the input fields in the form with the current values of the selected row.

    values$navigation_form_mode = "edit"
    row_id = as.integer(sub(".*_([0-9]+)", "\\1", input$button_navigation_edit_form))
    values$navigation_edit_index = row_id

    navigation_position = values$navigation$Navigation_Position[row_id]
    navigation_id = values$navigation$Navigation_ID[row_id]
    navigation_title = values$navigation$Title[row_id]

    updateSelectInput(
      session = session,
      inputId = "navigation_position",
      label = "Navigation-Position",
      selected = navigation_position
    )
    updateSelectInput(
      session = session,
      inputId = "navigation_id",
      label = "Navigation-ID",
      selected = navigation_id
    )
    updateTextInput(
      session = session,
      inputId = "navigation_title",
      label = "Title",
      value = navigation_title
    )

  })


  # EDIT row.


  validate_navigation_edit <- eventReactive(input$button_navigation_edit, {
    validate(
      need(input$navigation_position != "", "Position missing."),
      need(input$navigation_id != "", "ID missing."),
      need(input$navigation_title != "", "Title missing."),
      need(str_detect(input$navigation_position, "^([0-9]+)(\\.[0-9]+)*$"),
           "Invalid characters in Position. Only numbers and dots as dividers are valid."),
      need(!input$navigation_position %in% values$navigation$Navigation_Position[
        -as.integer(sub(".*_([0-9]+)", "\\1", input$button_navigation_edit_form))
      ], "Position already existing."),
      need(!input$navigation_id %in% values$navigation$Navigation_ID[
        -as.integer(sub(".*_([0-9]+)", "\\1", input$button_navigation_edit_form))
      ], "ID already existing.")
    )

    paste0("<span style='color:green'><b>", input$navigation_id, "</b> sucessfully edited.</span>")
  })
  
  
  observeEvent(input$button_navigation_edit, {
    output$validate_navigation_edit <- renderText({
      validate_navigation_edit()
    })
  }, priority = 10)
  
  
  observeEvent({
    input$button_navigation_edit_form
    input$button_import_settings
  }, {
    output$validate_navigation_add <- renderText({""})
    output$validate_navigation_edit <- renderText({""})
  }, priority = 10)


  observeEvent(input$button_navigation_edit, {
    # Edit the current selected row with the new values.

    validate_navigation_edit()

    table = values$navigation
    row_id = as.integer(sub(".*_([0-9]+)", "\\1", input$button_navigation_edit_form))

    table$Navigation_Position[row_id] = input$navigation_position
    table$Navigation_ID[row_id] = input$navigation_id
    table$Title[row_id] = input$navigation_title

    position = str_replace(table$Navigation_Position, "\\.", "#")
    position = str_replace_all(position, "\\.", "")
    position = str_replace(position, "#", "\\.")
    position = as.numeric(position)
    values$navigation = table[order(position),]
  })


  # DELETE row.


  observeEvent(input$button_navigation_delete, {
    # Delete the corresponding row.

    row_id = as.integer(sub(".*_([0-9]+)", "\\1", input$button_navigation_delete))
    values$navigation = values$navigation[-row_id,]
    click("button_navigation_add_form")
  })


  observeEvent(input$button_navigation_delete_all, {
    # Delete all rows.

    values$navigation = values$navigation[0,]
    click("button_navigation_add_form")
  })


  observeEvent(values$navigation_form_mode, {

    output$h3_navigation <- renderText({
      if (values$navigation_form_mode == "add") {
        "<h3><b>Add</b> to Navigation</h3>"
      } else if (values$navigation_form_mode == "edit") {
        "<h3><b>Edit</b> Navigation</h3>"
      }
    })

  })



  #### table_module. ####



  output$table_module <- renderDT({
    table = values$module
    table$Edit = 0
    table$Edit[values$module_edit_index] = 1

    table = .buttons_in_dt(table, "module", hidden_columns=c(1,4))

    if (values$module_edit_index != -1) {
      table = table %>%
        formatStyle(
          columns = "Edit",
          target = "row",
          backgroundColor = styleEqual(c(1), c("#5bc0de")))
    }

    table
  })


  output$module_form_mode <- reactive({
    values$module_form_mode
  })
  outputOptions(output, 'module_form_mode', suspendWhenHidden=FALSE)


  # CREATE row.


  observeEvent(input$button_module_add_form, {
    # Empty the input fields in the form.

    values$module_form_mode = "add"
    values$module_edit_index = -1
    
    shinyjs::reset("module_id")
    shinyjs::reset("module_return")
  })


  validate_module_add <- eventReactive(input$button_module_add, {
    validate(
      need(input$module_id != "", "ID missing."),
      need(str_detect(input$module_id, "^[0-9]", negate=TRUE), "ID can't start with a number."),
      need(!input$module_id %in% values$module$Module_ID, "ID already existing.")
    )

    paste0("<span style='color:green'><b>", input$module_id, "</b> sucessfully added.</span>") 
  })
  
  
  observeEvent(input$button_module_add, {
    output$validate_module_add <- renderText({
      validate_module_add()
    })
  }, priority = 10)
  
  
  observeEvent({
    input$button_module_add_form
    input$button_module_delete
    input$button_module_delete_all
    input$button_import_settings
  }, {
    output$validate_module_add <- renderText({""})
    output$validate_module_edit <- renderText({""})
  }, priority = 10)


  observeEvent(input$button_module_add, {
    # Insert new row in the data.table.

    validate_module_add()

    table = values$module
    values$hidden_module_id = values$hidden_module_id + 1

    new_row = data.table(
      Hidden_Module_ID = paste("Module", values$hidden_module_id, sep="_"),
      Module_ID = input$module_id,
      Return = input$module_return
    )

    values$module = rbind(table, new_row)

  })


  # SELECT row.


  observeEvent(input$button_module_edit_form, {
    # Fill the input fields in the form with the current values of the selected row.

    values$module_form_mode = "edit"
    row_id = as.integer(sub(".*_([0-9]+)", "\\1", input$button_module_edit_form))
    values$module_edit_index = row_id

    if (row_id == "") {
      module_id = ""
      module_return = ""
    } else {
      module_id = values$module$Module_ID[row_id]
      module_return = values$module$Return[row_id]
    }

    updateTextInput(
      session = session,
      inputId = "module_id",
      label = "Module-ID",
      value = module_id
    )
    updateCheckboxInput(
      session = session,
      inputId = "module_return",
      label = "Return",
      value = module_return
    )

  })


  # EDIT row.


  validate_module_edit <- eventReactive(input$button_module_edit, {
    validate(
      need(input$module_id != "", "ID missing."),
      need(str_detect(input$module_id, "^[0-9]", negate=TRUE), "ID can't start with a number."),
      need(!input$module_id %in% values$module$Module_ID[
        -as.integer(sub(".*_([0-9]+)", "\\1", input$button_module_edit_form))
      ], "ID already existing.")
    )

    paste0("<span style='color:green'><b>", input$module_id, "</b> sucessfully edited.</span>") 
  })
  
  
  observeEvent(input$button_module_edit, {
    output$validate_module_edit <- renderText({
      validate_module_edit()
    })
  }, priority = 10)
  
  
  observeEvent({
    input$button_module_edit_form
    input$button_import_settings
  }, {
    output$validate_navigation_add <- renderText({""})
    output$validate_navigation_edit <- renderText({""})
  }, priority = 10)

  
  observeEvent(input$button_module_edit, {
    # Edit the current selected row with the new values.

    validate_module_edit()

    table = values$module
    row_id = as.integer(sub(".*_([0-9]+)", "\\1", input$button_module_edit_form))

    table$Module_ID[row_id] = input$module_id
    table$Return[row_id] = input$module_return

    values$module = table

  })


  # DELETE row.


  observeEvent(input$button_module_delete, {
    # Delete the corresponding row.

    row_id = as.integer(sub(".*_([0-9]+)", "\\1", input$button_module_delete))
    values$module = values$module[-row_id,]
    click("button_module_add_form")
  })


  observeEvent(input$button_module_delete_all, {
    # Delete all rows.

    values$module = values$module[0,]
    click("button_module_add_form")
  })


  observeEvent(values$module_form_mode, {

    output$h3_module <- renderText({
      if (values$module_form_mode == "add") {
        "<h3><b>Add</b> to Module</h3>"
      } else if (values$module_form_mode == "edit") {
        "<h3><b>Edit</b> Module</h3>"
      }
    })

  })



  #### table_navigation_module. ####



  output$table_navigation_module <- renderDT({
    table = values$navigation_module
    table$Edit = 0
    table$Edit[values$navigation_module_edit_index] = 1

    table = .buttons_in_dt(table, "navigation_module", hidden_columns=c(1,2,4,7))

    if (values$navigation_module_edit_index != -1) {
      table = table %>%
        formatStyle(
          columns = "Edit",
          target = "row",
          backgroundColor = styleEqual(c(1), c("#5bc0de")))
    }

    table
  })


  output$navigation_module_form_mode <- reactive({
    values$navigation_module_form_mode
  })
  outputOptions(output, 'navigation_module_form_mode', suspendWhenHidden=FALSE)


  # CREATE row.


  observeEvent(input$button_navigation_module_add_form, {
    # Empty the input fields in the form.

    values$navigation_module_form_mode = "add"
    values$navigation_module_edit_index = -1
    
    updateSelectInput(
      session = session,
      inputId = "navigation_module_navigation_id",
      label = "Navigation-ID",
      selected = NULL
    )
    updateSelectInput(
      session = session,
      inputId = "navigation_module_module_id",
      label = "Module-ID",
      selected = NULL
    )
    updateTextInput(
      session = session,
      inputId = "navigation_module_instance_id",
      label = "Module-Instance-ID",
      value = ""
    )
  })


  validate_navigation_module_add <- eventReactive({
    input$button_navigation_module_add
  }, {
    validate(
      need(input$navigation_module_navigation_id != "", "No Navigation-ID selected"),
      need(input$navigation_module_module_id != "", "No Module-ID selected."),
      need(input$navigation_module_instance_id != "", "Module-Instance-ID missing."),
      need(!input$navigation_module_instance_id %in%
             values$navigation_module$Module_Instance_ID, "Module-Instance-ID already existing.")
    )

    paste0("<span style='color:green'><b>", input$navigation_module_instance_id, "</b> sucessfully added.</span>") 
  })
  
  
  observeEvent(input$button_navigation_module_add, {
    output$validate_navigation_module_add <- renderText({
      validate_navigation_module_add()
    })
  }, priority = 10)
  
  
  observeEvent({
    input$button_navigation_module_add_form
    input$button_navigation_module_delete
    input$button_navigation_module_delete_all
    input$button_import_settings
  }, {
    output$validate_navigation_module_add <- renderText({""})
    output$validate_navigation_module_edit <- renderText({""})
  }, priority = 10)
  

  observeEvent(input$button_navigation_module_add, {
    # Insert new row in the data.table.

    validate_navigation_module_add()

    table = values$navigation_module

    values$hidden_navigation_module_id = values$hidden_navigation_module_id + 1

    new_row = data.table(
      Hidden_Navigation_Module_ID = paste("Navigation_Module", values$hidden_navigation_module_id, sep="_"),
      Hidden_Navigation_ID = values$navigation$Hidden_Navigation_ID[
        values$navigation$Navigation_ID == input$navigation_module_navigation_id
        ],
      Navigation_ID = input$navigation_module_navigation_id,
      Hidden_Module_ID = values$module$Hidden_Module_ID[
        values$module$Module_ID == input$navigation_module_module_id
        ],
      Module_ID = input$navigation_module_module_id,
      Module_Instance_ID = input$navigation_module_instance_id
    )

    values$navigation_module = rbind(table, new_row)

  })


  # SELECT row.


  observeEvent(input$button_navigation_module_edit_form, {
    # Fill the input fields in the form with the current values of the selected row.

    values$navigation_module_form_mode = "edit"
    row_id = as.integer(sub(".*_([0-9]+)", "\\1", input$button_navigation_module_edit_form))
    values$navigation_module_edit_index = row_id

    navigation_id = values$navigation_module$Navigation_ID[row_id]
    module_id = values$navigation_module$Module_ID[row_id]
    instance_id = values$navigation_module$Module_Instance_ID[row_id]

    updateSelectInput(
      session = session,
      inputId = "navigation_module_navigation_id",
      label = "Navigation-ID",
      selected = navigation_id
    )
    updateSelectInput(
      session = session,
      inputId = "navigation_module_module_id",
      label = "Module-ID",
      selected = module_id
    )
    updateTextInput(
      session = session,
      inputId = "navigation_module_instance_id",
      label = "Module-Instance-ID",
      value = instance_id
    )

  })


  # EDIT row.

  validate_navigation_module_edit <- eventReactive(input$button_navigation_module_edit, {
    validate(
      need(input$navigation_module_instance_id != "", "Module-Instance-ID missing."),
      need(!input$navigation_module_instance_id %in%
             values$navigation_module$Module_Instance_ID[
               -match(input$navigation_module_instance_id, values$navigation_module)
             ], "Module-Instance-ID already existing.")
    )

    paste0("<span style='color:green'><b>", input$navigation_module_instance_id, "</b> sucessfully edited.</span>")
  })
  
  
  observeEvent(input$button_navigation_module_edit, {
    output$validate_navigation_module_edit <- renderText({
      validate_navigation_module_edit()
    })
  }, priority = 10)
  
  
  observeEvent({
    input$button_navigation_module_edit_form
    input$button_import_settings
  }, {
    output$validate_navigation_module_add <- renderText({""})
    output$validate_navigation_module_edit <- renderText({""})
  }, priority = 10)


  observeEvent(input$button_navigation_module_edit, {
    # Edit the current selected row with the new values.

    validate_navigation_module_edit()

    table = values$navigation_module
    row_id = as.integer(sub(".*_([0-9]+)", "\\1", input$button_navigation_module_edit_form))

    table$Hidden_Navigation_ID[row_id] = values$navigation$Hidden_Navigation_ID[
      values$navigation$Navigation_ID == input$navigation_module_navigation_id
    ]
    table$Navigation_ID[row_id] = input$navigation_module_navigation_id
    table$Hidden_Module_ID[row_id] = values$module$Hidden_Module_ID[
      values$module$Module_ID == input$navigation_module_module_id
    ]
    table$Module_ID[row_id] = input$navigation_module_module_id
    table$Module_Instance_ID[row_id] = input$navigation_module_instance_id

    values$navigation_module = table
  })



  # DELETE row.


  observeEvent(input$button_navigation_module_delete, {
    # Delete the corresponding row.

    row_id = as.integer(sub(".*_([0-9]+)", "\\1", input$button_navigation_module_delete))
    values$navigation_module = values$navigation_module[-row_id,]
    click("button_new_row_navigation_module")
  })

  observeEvent(input$button_navigation_module_delete_all, {
    # Delete all rows.

    values$navigation_module = values$navigation_module[0,]
    click("button_new_row_navigation_module")
  })


  observeEvent(values$navigation_module_form_mode, {

    output$h3_navigation_module <- renderText({
      if (values$navigation_module_form_mode == "add") {
        "<h3><b>Add</b> to Navigation-Module</h3>"
      } else if (values$navigation_module_form_mode == "edit") {
        "<h3><b>Edit</b> Navigation-Module</h3>"
      }
    })

  })



  #### Misc. ####



  observeEvent(input$navigation_title, {
    updateTextInput(
      session = session,
      inputId = "navigation_id",
      value = .title_to_valid_id(input$navigation_title)
    )
  })


  observeEvent(input$navigation_module_module_id, {
    # Suggestion for Module_Instance_ID based on Module_ID.

    if (input$navigation_module_module_id == "") {
      instance_id = ""
    } else {
      new_index = values$navigation_module$Module_Instance_ID
      new_index = new_index[str_detect(new_index,
                                       paste(input$navigation_module_module_id, "_", sep=""))]

      if (length(new_index) == 0) {
        instance_id = paste(input$navigation_module_module_id, "1", sep="_")
      } else {
        new_index = sort(new_index, decreasing=TRUE)
        new_index = str_split(new_index, "_")[[1]]
        new_index = as.integer(new_index[length(new_index)])
        instance_id = paste(input$navigation_module_module_id, new_index + 1, sep="_")
      }

      if (values$navigation_module_form_mode == "edit") {
        if (nrow(values$navigation) > 0) {
          if (input$navigation_module_module_id ==
              values$navigation_module$Module_ID[values$navigation_module_edit_index]) {
            instance_id = values$navigation_module$Module_Instance_ID[values$navigation_module_edit_index]
          }
        }
      }
    }

    updateTextInput(
      session = session,
      inputId = "navigation_module_instance_id",
      label = "Module-Instance-ID",
      value = instance_id
    )

  })


  #### table overreaching effects. ####





  # CREATE/EDIT/DELETE row in navigation/module.

  observeEvent({
    values$navigation
    values$module
  }, {

    # Update selectInputs.
    updateSelectInput(
      session = session,
      inputId = "navigation_module_navigation_id",
      choices = .get_list_for_navigation_select(values$navigation)
    )
    updateSelectInput(
      session = session,
      inputId = "navigation_module_module_id",
      choices = values$module$Module_ID
    )

    # Changes in navigation/module lead to changes in navigation_module.

    table = values$navigation_module[,c("Hidden_Navigation_Module_ID", "Hidden_Navigation_ID",
                                        "Hidden_Module_ID", "Module_Instance_ID")]

    table = inner_join(table, values$navigation[,c("Hidden_Navigation_ID", "Navigation_ID")],
                       by="Hidden_Navigation_ID")
    table = inner_join(table, values$module[,c("Hidden_Module_ID", "Module_ID")],
                       by="Hidden_Module_ID")

    table = table[,c("Hidden_Navigation_Module_ID", "Hidden_Navigation_ID", "Navigation_ID",
                     "Hidden_Module_ID", "Module_ID", "Module_Instance_ID")]

    values$navigation_module = as.data.table(table)

  })


  ##


  observeEvent({
    input_fields()
    values$navigation
    values$module
    values$navigation_module
  }, {

    if (input$checkbox_multiple_files) {
      choices = c("global.R", "ui.R", "server.R")
    } else {
      choices = c("app.R")
    }

    if (input$checkbox_modules) {
      module_choices = values$code_module$Filename[!values$code_module$Filename %in%
                                                     c("global.R", "ui.R", "server.R")]
      choices = c(choices, module_choices)
      choices = choices[!choices %in% c("custom.css", "custom.js")]
    }

    if (input$select_filename_2 %in% choices) {
      updateSelectInput(
        session = session,
        inputId = "select_filename_2",
        choices = choices,
        selected = input$select_filename_2
      )
    } else {
      updateSelectInput(
        session = session,
        inputId = "select_filename_2",
        choices = choices
      )
    }

  })


  output$code_ui_modules <- renderUI({
    validate(
      .check_navigation_position(values$navigation)
    )

    text = .prepare_code(input$select_filename_2, values$code_module)

    HTML(paste("<pre>", text, "</pre>"))

  })



  # App network graph.
  output$app_structure <- renderVisNetwork({
    validate(
      .check_navigation_position(values$navigation)
    )

    if (!input$checkbox_modules) {
      values$app_structure = .app_structure(
        values$navigation,
        values$module[0:0,],
        values$navigation_module[0:0,],
        module_io
      )
    } else {
      values$app_structure = .app_structure(
        values$navigation,
        values$module,
        values$navigation_module,
        module_io
      )
    }

    values$app_structure

  })

  
  observeEvent(input$button_save_code, {
    validate(
      .check_navigation_position(values$navigation)
    )
    
    if (!.check_project_options(paths())[["delete_possible"]]) {
      showNotification("Export of code unsucessful.\n
                       Project Structure needs to be created beforehand.",
                       type = "error")
    } else {
      paths_in_directory = values$code_module$Filename
      if (input$checkbox_create_project_folder) {
        paths_in_directory = paste(basename(paths()[["project"]]), paths_in_directory, sep="/")      
      }
      
      text_1 = paste0("<p><b>", 
                      length(paths_in_directory),
                      "</b> files within the following directory will be created or updated.</p>")
      text_2 = paste0("<pre style='text-align: left'>", 
                      paths()[["directory"]], 
                      "</pre>")
      text_3 = paste0("<pre style='text-align: left; height: 300px; overflow: auto;'>",
                      paste(paths_in_directory, collapse="<br>"),
                      "</pre>")
      
      text = paste(text_1, text_2, text_3, sep="<br>")
      
      shinyalert(
        inputId = "button_save_code_2",
        title = "Warning",
        text = text,
        type = "warning",
        closeOnEsc = TRUE,
        closeOnClickOutside = TRUE,
        html = TRUE,
        showConfirmButton = TRUE,
        showCancelButton = TRUE,
        confirmButtonText = "Export all code",
        cancelButtonText = "Cancel",
        size = "m",
        animation = TRUE,
        className = "shinyalert-with-scrollbar"
      )
    }
  })
  

  observeEvent(input$button_save_code_2, {
    if (input$button_save_code_2) {
      validate(
        .check_navigation_position(values$navigation)
      )
      
      if (!.check_project_options(paths())[["delete_possible"]]) {
        showNotification("Export of code unsucessful.\n
                       Project Structure needs to be created beforehand.",
                         type = "error")
      } else {
        .export_settings(paths(), input_fields(),
                         values$navigation, values$module, values$navigation_module)
        
        if (length(input$file_image_upload$datapath) != 0) {
          file.copy(from = input$file_image_upload$datapath,
                    to = paste(paths()[["project"]], "app/www/logo.jpg", sep="/"),
                    overwrite = TRUE,
                    copy.mode = TRUE)
        }
        
        .export_all_code(paths(), input$checkbox_multiple_files, values$code_module)
      }
    }
  })


  observeEvent({
    input_fields()
    values$navigation
    values$module
    values$navigation_module
  }, {

    values$code = .create_code(input_fields(), values$navigation)

    if (input$checkbox_modules) {
      values$code_module = .create_module_code(values$code,
                                               values$navigation, values$module, values$navigation_module,
                                               input$select_suffix_style)
    } else {
      values$code_module = values$code
    }

  }, priority = -1)

}

