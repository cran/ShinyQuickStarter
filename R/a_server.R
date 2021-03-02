.shiny_quick_builder_server <- function() {
  
  server <- function(input, output, session) {
    
    
    #### Initial Setup. ####

    
    values <- reactiveValues(
      elements = data.table(
        parent = character(0),
        sqs_id = character(0),
        ui_function = character(0),
        server_function = character(0)
      ),
      arguments = data.table(
        sqs_id = character(0),
        function_name = character(0),
        argument = character(0),
        value = character(0)
      ),
      make_droppable = NULL,
      highlighted = NULL,
      update_possible = FALSE,
      errors = NULL,
      rerender_options = 0,
      drop_zone_ui = "",
      drop_zone_hrefs = c(),
      navigation_tree = NULL,
      ui_code = "",
      server_code = "",
      module_code = "",
      export_code_directory = getwd(),
      export_folders_directory = getwd(),
      export_file_paths = c(),
      export_folder_paths = c()
    )
    
    
    observe({
      
      # Insert Badges for the UI Elements.
      elements$class = str_replace_all(elements$category, "[ ()]", "_")
      
      for (c in unique(elements$category)) {
        if (c %in% c("UI Layout", "UI Inputs", "UI Outputs")) {
          rows = elements[elements$category == c,]
          template = "p(rel='%s', '%s', tags$sup('%s'), class='sqs_ui_type %s', style='display:table')"
          badges = sprintf(template, rows$function_name, rows$function_name, rows$package, rows$class)
          badges = paste(badges, collapse=",")
          ui = paste(badges, collapse=",")
          ui = sprintf("tagList(%s)", ui)
          
          ui = eval(parse(text=ui))
          
          insertUI(
            selector = sprintf("#%s", str_replace_all(c, "[ ()]", "_")),
            where = "beforeEnd",
            ui = ui,
            immediate = TRUE
          )
        }
      }
      
      # Trigger JS that makes the badges draggable into the drop zone.
      session$sendCustomMessage("set_draggable", list(selector=".sqs_ui_type"))
      
      # Names list for page type options.
      types = elements$function_name[elements$category == "UI Page"]
      choices_grouped = list(
        "Without Top-Level Navigation" = list("fluidPage", "fillPage", "fixedPage", "bootstrapPage"),
        "With Top-Level Navigation" = list("navbarPage", "dashboardPage"),
        "Module" = list("tagList")
      )
      options_grouped = list(
        "<p>fluidPage <sup>shiny</sup></p>",
        "<p>fillPage <sup>shiny</sup></p>",
        "<p>fixedPage <sup>shiny</sup></p>",
        "<p>bootstrapPage <sup>shiny</sup></p>",
        "<p>navbarPage <sup>shiny</sup></p>",
        "<p>dashboardPage <sup>shinydashboard</sup></p>",
        "<p>tagList <sup>shiny</sup></p>"
      )
      
      updatePickerInput(
        session = session,
        inputId = "sqs_page_type",
        choices = choices_grouped,
        selected = "fluidPage"#,
        #choicesOpt = list(content = options_grouped)
      )

    }, autoDestroy = TRUE)
    
    
    volumes <- c("Current Working Directory" = getwd(), Home = path_home(), getVolumes()())
    shinyDirChoose(
      input,
      id = "export_code_directory",
      roots = volumes,
      session = session,
      restrictions = system.file(package = "base")
    )
    shinyDirChoose(
      input,
      id = "export_folders_directory",
      roots = volumes,
      session = session,
      restrictions = system.file(package = "base")
    )

    
    #### Edit/Display Mode. ####
    
    
    observeEvent(input$edit_mode, {
      
      # Show or hide the container around the ui elements.
      session$sendCustomMessage("edit_mode", input$edit_mode)
      
      # Deselect ui element in navigation tree and drop zone.
      if (!input$edit_mode) {
        values$highlighted = NULL
        values$options_tagList = tagList("Nothing selected.")
        session$sendCustomMessage("highlight", list(sqs_id = "", id = -1))
        values$errors = NULL
      }
      
    })
    
    
    output$validation_errors <- renderUI({
      if (length(values$errors) > 0) {
        HTML(sprintf("Validation error detected.", length(values$errors)))
      } else {
        HTML("")
      }
    })
    
    
    observeEvent(input$help_tour_start, {
      updateSwitchInput(
        session = session,
        inputId = "edit_mode",
        value = TRUE
      )
    })
    
    
    observeEvent(input$update_displayed_tabs, {
      if (input$sqs_page_type == "tagList") {
        session$sendCustomMessage("show_tabs", list("id" = "#code_tabs", 
                                                    "show" = c("module.R"),
                                                    "hide" = c("ui.R", "server.R")))
      } else {
        session$sendCustomMessage("show_tabs", list("id" = "#code_tabs", 
                                                    "hide" = c("module.R"),
                                                    "show" = c("ui.R", "server.R")))
      }
      
      if (!is.null(values$highlighted)) {
        if (is.na(values$elements$server_function[values$elements$sqs_id == values$highlighted])) {
          session$sendCustomMessage("show_tabs", list("id" = "#options_tabs", 
                                                      "show" = c("UI"),
                                                      "hide" = c("Server")))
        } else {
          session$sendCustomMessage("show_tabs", list("id" = "#options_tabs", 
                                                      "show" = c("UI", "Server"),
                                                      "hide" = NULL))
        }
      }
    })
    
    
    #### Render Code. ####
    
    
    output$ui_code <- renderText({

      ui_code = ""
      
      if (nrow(values$elements) > 0) {
        if (length(values$errors) == 0) {
          ui_code = .create_ui_code(
            "ui <- %s",
            values$elements,
            values$arguments[values$arguments$function_name %in% values$elements$ui_function,],
            insertUI=FALSE,
            include_defaults=FALSE
          )
        } else {
          ui_code = unlist(values$errors)
        }
      }
      values$ui_code = ui_code

      HTML(paste0("<pre>", ui_code, "</pre>"))
      
    })
    outputOptions(output, "ui_code", suspendWhenHidden = FALSE)
    
    
    output$server_code <- renderText({
      server_code = ""
      
      if (nrow(values$elements) > 0) {
        if (length(values$errors) == 0) {
          server_code = .create_server_code(values$elements, values$arguments, insertServer=FALSE)  
        } else {
          server_code = unlist(values$errors)
        }
      }
      values$server_code = server_code
      
      HTML(paste0("<pre>", values$server_code, "</pre>"))
    })
    outputOptions(output, "server_code", suspendWhenHidden = FALSE)

    
    output$module_code <- renderText({
      module_code = ""
      
      if (nrow(values$elements) > 0) {
        if (length(values$errors) == 0) {
          module_code = .create_module_code(values$ui_code, values$server_code,
                                            input$module_name, input$module_suffix)
        } else {
          module_code = unlist(values$errors)
        }
      }
      values$module_code = module_code
      
      HTML(paste0("<pre>", values$module_code, "</pre>"))
    })
    outputOptions(output, "module_code", suspendWhenHidden = FALSE)
    
    
    #### Server Code for dropped UI Elements. ####
    
    
    observeEvent({
      values$elements
      values$arguments
    }, {

      req(is.null(isolate(values$errors)))
      
      server_code = .create_server_code(values$elements, values$arguments, insertServer=TRUE)
      eval(parse(text=server_code))

    })
    
    
    #### Change Page Type. ####
    
    
    observeEvent(input$sqs_page_type, {
      
      # Allow event if validation errors.
      values$errors = NULL
      
      # Deselect ui element in navigation tree and drop zone.
      values$highlighted = NULL
      
      # Delete all elements in the drop zone.
      values$elements = values$elements[0,]
      values$arguments = values$arguments[0,]
      
      # Trigger the insertion of the page element.
      insert_ui = 'Shiny.setInputValue(
                    id = "insert_ui",
                    value = { sqs_id: %s, parent: "%s", sqs_type: "%s", highlight: true }
                  )'
      runjs(sprintf(insert_ui, runif(1), "drop_zone", input$sqs_page_type))
      
      # Show only relevant ui elements.
      hide_badges = elements$function_name[!str_detect(elements$page_type, input$sqs_page_type)]
      hide_badges = hide_badges[!is.na(hide_badges)]
      session$sendCustomMessage("hide_badges", hide_badges)
      
      #print(sprintf("CHANGE PAGE TYPE TO %s.", input$sqs_page_type))
      
      # Show only relevant code tabs.
      if (input$sqs_page_type == "tagList") {
        session$sendCustomMessage("show_tabs", list("id" = "#code_tabs", 
                                                    "show" = c("module.R"),
                                                    "hide" = c("ui.R", "server.R")))
      } else {
        session$sendCustomMessage("show_tabs", list("id" = "#code_tabs", 
                                                    "hide" = c("module.R"),
                                                    "show" = c("ui.R", "server.R")))
      }
      
    })

    
    #### Render Drop Area. ####
    
    
    observeEvent({
      values$elements
      values$arguments
    }, {

      req(nrow(values$elements) > 0)
      req(is.null(isolate(values$errors)))
      
      # Create HTML for the drop zone.
      ui = ""
      
      if (nrow(values$elements) > 0) {
        ui = .recursive.ui_code("%s", "drop_zone", values$elements, 
                                values$arguments[values$arguments$function_name %in% values$elements$ui_function,],
                                insertUI=TRUE, include_defaults=FALSE)
        ui = str_replace_all(ui, ", %s", "")
        ui = eval(parse(text=ui))
        for (index in 1:length(ui)) {
          ui[[index]] = .recursive.design_changes(ui[[index]], values$elements, values$arguments)
        }
      }
      
      values$drop_zone_ui = ui

      runjs("$( 'div[sqs_id=drop_zone] .loading_foreground' ).css('display', 'inline')")
      
      # Replace HTML for Drop Area.
      removeUI(
        selector = paste0("div[sqs_id=drop_zone_content]"),
        immediate = TRUE
      )
      
      insertUI(
        selector = paste0("div[sqs_id=drop_zone]"),
        where = "afterBegin",
        ui = HTML(sprintf("<div sqs_id='drop_zone_content' style='display:none'>%s</div>", as.character(ui))),
        immediate = TRUE
      )
      
      # dashboardPage: Trigger JS that applies some custom changes that would happen at app start.
      if (input$sqs_page_type == "dashboardPage") {
        session$sendCustomMessage("set_shinydashboard", list(
          "dashboardPage_skin" = str_replace_all(
            values$arguments$value[values$arguments$function_name == "dashboardPage" &
                                     values$arguments$argument == "skin"], "'", ""),
          "dashboardHeader_titleWidth" = str_replace_all(
            values$arguments$value[values$arguments$function_name == "dashboardHeader" &
                                     values$arguments$argument == "titleWidth"], "'", ""),
          "dashboardSidebar_disable" = str_replace_all(
            values$arguments$value[values$arguments$function_name == "dashboardSidebar" &
                                     values$arguments$argument == "disable"], "'", ""),
          "dashboardSidebar_collapsed" = str_replace_all(
            values$arguments$value[values$arguments$function_name == "dashboardSidebar" &
                                     values$arguments$argument == "collapsed"], "'", ""),
          "dashboardSidebar_width" = str_replace_all(
            values$arguments$value[values$arguments$function_name == "dashboardSidebar" &
                                     values$arguments$argument == "width"], "'", ""),
          "menuItem_selected" = 
            values$arguments$value[values$arguments$function_name == "menuItem" &
                                     values$arguments$argument == "selected"], 
          "menuItem_startExpanded" = 
            values$arguments$value[values$arguments$function_name == "menuItem" &
                                     values$arguments$argument == "startExpanded"]
        ))
      }

      # Trigger JS that makes droppable elements droppable.
      droppable_elements = elements[elements$droppable == "TRUE",]
      for (i in 1:nrow(droppable_elements)) {
        selector = sprintf("div[sqs_type='%s']", droppable_elements$function_name [i])
        session$sendCustomMessage("set_droppable", selector)
      }
      
      # Update navigation tree.
      if (nrow(values$elements) > 0) {
        values$navigation_tree = .recursive.navigation_tree(
          input$sqs_page_type,
          0,
          values$elements$sqs_id[values$elements$ui_function == input$sqs_page_type],
          values$elements,
          values$arguments,
          list()
        )$tree
        
        session$sendCustomMessage("update_tree", list(data=values$navigation_tree))
      }

      # Sortable UI Elements.
      #session$sendCustomMessage("set_draggable_element", list(selector="div .sqs_ui_element"))
      #session$sendCustomMessage("set_droppable_element", list(selector="div .sqs_ui_element"))
      #session$sendCustomMessage("set_sortable", list(
      #  selector=sprintf("div[sqs_id=%s]", values$elements$sqs_id[values$elements$parent == "drop_zone"]))
      #)
      
      values$display_drop_zone_content = runif(1)
      
      #print("RERENDER UI.")
      
    })
    

    observeEvent({
      values$highlighted
      values$click
      values$display_drop_zone_content
    }, {
      
      # At re-rendering the drop zone the app starts back at the first app page. Because of this the
      # user would always have to navigate back to where they worked at.
      
      # Find all hrefs in the drop zone.
      hrefs = .recursive.href(list(ui=values$drop_zone_ui, hrefs=c()))$hrefs
      
      if (length(hrefs) > 0 & !is.null(values$highlighted)) {
        temp = inner_join(values$elements, elements[,c("function_name", "has_href")], 
                          by=c("ui_function"="function_name"))
        temp$href[!is.na(temp$has_href) & temp$has_href == "TRUE"] = hrefs
        
        # A dashboardPage splits the navigation and the content in two elements.
        # Copy the hrefs to the navigation elements to the content elements based on the connective tabName.
        temp = left_join(temp, values$arguments[values$arguments$argument == "tabName", 
                                                c("sqs_id", "value")], by="sqs_id")
        temp$value = str_replace_all(temp$value, "'", "")
        temp$value[!is.na(temp$value)] = paste0("#shiny-tab-", temp$value[!is.na(temp$value)])
        temp$href[!is.na(temp$value)] = temp$value[!is.na(temp$value)]
        
        if (nrow(temp) > 0) {
          
          temp_id = values$highlighted
          
          if (temp_id %in% temp$sqs_id) {
            # Find href of the nearest navigation element.
            while (temp$parent[temp$sqs_id == temp_id] != "drop_zone" &
                   is.na(temp$href[temp$sqs_id == temp_id])) {
              temp_id = temp$parent[temp$sqs_id == temp_id]
            }
            
            href = temp$href[temp$sqs_id == temp_id]
            
            if (!is.na(href) & href != "#") {
              # Trigger a click on the nearest navigation element.
              session$sendCustomMessage("click_href", href)
              #print(sprintf("CLICK ON %s.", href))
            }
          }
          
        }
      }
      
      # Insert html with drop_zone_content "display:none"
      # After href navigation set "display:''" of updating animation
      runjs("$( 'div[sqs_id=drop_zone_content]').css('display', '')")
      runjs("$( 'div[sqs_id=drop_zone] .loading_foreground').css('display', 'none')")
      
    })
    

    #### Insert UI Element. ####
    
    
    observeEvent(input$insert_ui, {

      req(input$edit_mode)
      req(is.null(values$errors))
      
      # Create the new ui element and all required/sensible child ui elements.
      temp = .recursive.new_elements_arguments(
        input$insert_ui, 
        values$elements[0,],
        values$arguments[0,]
      )

      new_element = temp$new_elements
      new_arguments = temp$new_arguments
      
      # dashboardPage: Can't have both badge and subItems.
      if (any(c("menuItem", "menuSubItem") %in% new_element$ui_function)) {
        values$arguments$value[values$arguments$sqs_id == new_element$parent &
                                 values$arguments$argument == "badgeLabel"] = "'NULL'"
      }
      
      # Changed type to dashboardPage: first menuItem/tabItem with same tabName.
      if (input$insert_ui$sqs_type == "dashboardPage") {
        new_arguments$value[new_arguments$function_name == "menuItem" &
                              new_arguments$argument == "tabName"] =
          new_arguments$value[new_arguments$function_name == "tabItem" &
                                new_arguments$argument == "tabName"]
      }
      
      # Insert ui elements to global lists.
      values$elements = as.data.table(rbind(values$elements, new_element))
      values$arguments = as.data.table(rbind(values$arguments, new_arguments))
      
      #print(sprintf("ADDED %s FROM TYPE %s TO %s (+ required children).", 
      #              input$insert_ui$sqs_id, input$insert_ui$sqs_type, input$insert_ui$parent))
      
      # Trigger highlight when not in tour.
      if (input$insert_ui$highlight) {
        if (!endsWith(new_element$ui_function[1], "Page")) {
          values$highlighted_from_insert = new_element$sqs_id[1]
        } else {
          values$highlighted_from_insert = new_element$sqs_id[nrow(new_element)]
        }
      }
      
      values$update_possible = FALSE

    })
    
    
    #### Remove UI Element. ####
    
    
    observeEvent(input$remove_ui, {

      req(input$edit_mode)
      
      if (input$remove_ui$sqs_id %in% values$elements$sqs_id) {
        # Check if the ui element can be removed.
        sqs_type = values$elements$ui_function[values$elements$sqs_id == input$remove_ui$sqs_id]
        dont_delete = elements$function_name[!is.na(elements$removable) & elements$removable == "FALSE"]
        
        if (!sqs_type %in% dont_delete) {
          
          # Remove ui element with all child ui elements.
          remove_ids = .recursive.get_sub_ids(input$remove_ui$sqs_id, values$elements, c())
          values$elements = values$elements[!values$elements$sqs_id %in% remove_ids,]
          values$arguments = values$arguments[!values$arguments$sqs_id %in% remove_ids,]
          
          # Clear option area if removed element was highlighted.
          if (!is.null(values$highlighted)) {
            if (values$highlighted %in% remove_ids) {
              values$highlighted = NULL
              values$errors = NULL
            }
          }
          
          #print(sprintf("REMOVE %s.", input$remove_ui$sqs_id))
          
        }
      }
      
    })
    
    
    #### Highlight UI Element & Show Options. ####
    
    
    observeEvent(input$show_ui_options$update, {
      
      req(input$edit_mode)
      req(is.null(isolate(values$errors)))
      
      values$highlighted = input$show_ui_options$sqs_id
      values$update_possible = FALSE
    })
    
    
    observeEvent(values$highlighted_from_insert, {
      
      req(input$edit_mode)
      req(is.null(isolate(values$errors)))
      
      if (!is.null(values$highlighted_from_insert)) {
        values$highlighted = values$highlighted_from_insert
        values$highlighted_from_insert = NULL
        values$update_possible = FALSE
      }
    })
    
    
    observeEvent({
      values$highlighted
      values$elements
      values$arguments
    }, {
      
      req(input$edit_mode)
      
      select_nothing = FALSE
      
      if (is.null(values$highlighted)) {
        select_nothing = TRUE
      } else {
        if (!is.null(values$navigation_tree)) {
          if(length(which(unlist(values$navigation_tree) == values$highlighted)) != 0) {
            #print(sprintf("HIGHLIGHTED %s.", values$highlighted))

            id = which(unlist(values$navigation_tree) == values$highlighted)
            id = id[endsWith(names(id), "sqs_id")][[1]]
            
            session$sendCustomMessage("highlight", list(
              sqs_id = values$highlighted,
              id = as.integer(unlist(values$navigation_tree)[id - 1])
            ))
            
            values$click = runif(1)
          } else {
            select_nothing = TRUE
          }
        } else {
          select_nothing = TRUE
        }
      }
      
      if (select_nothing) {
        #print("HIGHLIGHT NOTHING.")
        session$sendCustomMessage("highlight", list(sqs_id = "", id = -1))
        values$options_tagList = tagList("Nothing selected.")
      }
      
    })
    
    
    observeEvent({
      values$highlighted
    }, {
      
      req(input$edit_mode)
      
      ui_options = "tagList('')"
      server_options = "tagList('')"
      
      if (is.null(isolate(values$errors))) {
        if (!is.null(values$highlighted)) {
          if (values$highlighted %in% values$elements$sqs_id) {
            
            # Create HTML for the options of the selected ui element.
            uie = isolate(values$elements)
            uia = isolate(values$arguments)
            element = uie[uie$sqs_id == values$highlighted,]
            arguments_current = uia[uia$sqs_id == values$highlighted,]
            arguments_all = arguments[arguments$function_name == element$ui_function |
                                        arguments$function_name == element$server_function,]
            
            if (nrow(arguments_all) != 0) {
              arguments_all = merge(arguments_all, arguments_current,
                                    by=c("function_name", "argument"), all.x=TRUE, all.y=TRUE)
              arguments_all = arguments_all[order(arguments_all$order),]

              ui_options = .ui_options_to_tagList(element, arguments_all)
              server_options = .server_options_to_tagList(element, arguments_all)
            } else {
              ui_options = "tagList('No arguments.')"
              server_options = "tagList('No arguments.')"
            }
          }
        } else {
          ui_options = "tagList('Nothing highlighted.')"
          server_options = "tagList('Nothing highlighted.')" 
        }
      }
      
      ui_options = eval(parse(text=ui_options))
      server_options = eval(parse(text=server_options))

      values$options_tagList = list("ui_options" = ui_options,
                                    "server_options" = server_options)
      
      #print("SET OPTIONS.")
      
    })
    
    
    observeEvent({
      values$highlighted
      values$options_tagList$ui_options
      values$options_tagList$server_options
    }, {
      if (input$edit_mode) {
        
        inputs = isolate(reactiveValuesToList(input))
        inputs = inputs[startsWith(names(inputs), "sqs_option_")]
        
        session$sendCustomMessage("setInputValues", names(inputs))
        
        if (!is.null(values$highlighted)) {
          if (is.na(values$elements$server_function[values$elements$sqs_id == values$highlighted])) {
            session$sendCustomMessage("show_tabs", list("id" = "#options_tabs", 
                                                        "show" = c("UI"),
                                                        "hide" = c("Server")))
          } else {
            session$sendCustomMessage("show_tabs", list("id" = "#options_tabs", 
                                                        "show" = c("UI", "Server"),
                                                        "hide" = NULL))
          }
          
          #print(sprintf("SHOW OPTIONS TO %s.", values$highlighted))
        }
        
      }
    })

    
    output$ui_options <- renderUI({
      if (!is.null(values$highlighted)) {
        values$options_tagList$ui_options
      } else {
        HTML("Nothing selected.")
      }
    })
    outputOptions(output, "ui_options", suspendWhenHidden = FALSE)
    
    
    output$server_options <- renderUI({
      if (!is.null(values$highlighted)) {
        values$options_tagList$server_options
      } else {
        HTML("Nothing selected.")
      }
    })
    outputOptions(output, "server_options", suspendWhenHidden = FALSE)
    
    
    observeEvent(values$rerender_options, {

      req(nrow(values$elements) > 0)

      #print("RERENDER SELECTED.")

      table = .join_tables(elements, arguments, values$elements, values$arguments)
      table = table[table$sqs_id == values$highlighted,]
      table = table[!is.na(table$choices) & startsWith(table$choices, "sqs_option_")]

      # TODO: dont rerender when selected changed, only when options changed
      # seems like every time the selected updates, the choices also update?

      if (nrow(table) > 0) {
        for (index in 1:nrow(table)) {
          if (table$ui[index] == "selectInput") {
            temp_choices = eval(parse(text=sprintf("input[['%s']]", table$choices[[index]])))
            updateSelectInput(
              session = session,
              inputId = table$internal_inputId[index],
              choices = temp_choices,
              selected = str_replace_all(table$value[index], "'", "")
            )
          } else if (table$ui[index] == "selectizeInput") {
            temp_choices = eval(parse(text=sprintf("input[['%s']]", table$choices[[index]])))
            updateSelectizeInput(
              session = session,
              inputId = table$internal_inputId[index],
              choices = temp_choices,
              selected = eval(parse(text=table$value[index]))
            )
          }
        }
      }

    })
    
    
    #### Update UI Element. ####
    
    
    observeEvent({
      reactiveValuesToList(input)
    }, {
      
      req(input$edit_mode)
      req(!is.null(values$highlighted))
      
      # Checks if the change was relevant to the highlighted UI Element.
      inputs = reactiveValuesToList(input)
      inputs = inputs[startsWith(names(inputs), "sqs_option_")]
      inputs = unlist(inputs)
      inputs = .combine_inputs(inputs)

      req(length(inputs) != 0)

      if (values$update_possible) {
        
        functions = c(values$elements$ui_function[values$elements$sqs_id == values$highlighted],
                      values$elements$server_function[values$elements$sqs_id == values$highlighted])
        args = arguments$internal_inputId[arguments$function_name %in% functions]
        
        inputs = inputs[names(inputs) %in% args]
        inputs[inputs == ""] = "NULL"
        inputs[is.na(inputs)] = "NA"
        inputs = inputs[sort(names(inputs))]
        old_values = values$arguments[values$arguments$sqs_id == values$highlighted,]
        old_values = left_join(old_values, 
                               arguments[,c("function_name", "order", "argument", "internal_inputId", 
                                            "transformation", "transformation_args")], 
                               by=c("function_name", "argument"))
        
        new_values = data.frame(
          internal_inputId = names(inputs),
          new_value = unlist(inputs)
        )
        new_values$internal_inputId = as.character(new_values$internal_inputId)

        req(nrow(new_values) > 0)
        
        all_values = left_join(old_values, new_values, by="internal_inputId")
        all_values = all_values[order(all_values$order),]
        all_values$value = str_replace_all(all_values$value, "'", "")
        all_values$value = as.character(all_values$value)
        all_values$new_value = as.character(all_values$new_value)
        all_values$value[is.na(all_values$value)] = "NA"
        all_values$new_value[is.na(all_values$new_value)] = "NULL"

        # Necessary if a plotlyOutput is included.
        req(all(all_values$new_value != "INVALID!"))

        # Check if an actual change occurred.
        changed_index = which(as.character(all_values$value) != as.character(all_values$new_value))
        changed = !all(as.character(all_values$value) == as.character(all_values$new_value))
        
        if (changed | length(values$errors) != 0) {
          updates = .arguments_update(values$highlighted, all_values, transform=TRUE)
          
          # Validate the input updates.
          values$errors = .validate_inputs(values$highlighted, values$elements, values$arguments, 
                                           updates$updates, updates$error_list)

          if (!is.null(values$errors)) {
            for (name in names(values$errors)) {
              session$sendCustomMessage(
                "insert_validations",
                list(name = name, validation_error = values$errors[[name]])
              )
            }
          } else {
            session$sendCustomMessage("remove_validations", "")
            values$updates = updates$updates
            #print("SET UPDATES.")
          }
          
          # Re-render Options if there was a change at co-dependent options.
          if ("choices" %in% all_values$argument[changed_index]) {
            values$rerender_options = values$rerender_options + 1
          }
        }
        
      } else {
        values$update_possible = TRUE
      }
      
    })
    
    
    observeEvent(values$updates, {
      
      req(input$edit_mode)
      req(!is.null(values$highlighted))
      req(!is.null(values$updates))
      
      values$arguments = values$arguments[values$arguments$sqs_id != values$highlighted,]
      values$arguments = rbind(values$arguments, values$updates)

      #print(sprintf("UPDATED %s.", values$highlighted))
      
    })
    
    
    #### Move UI Element. ####
    
    
    # observeEvent(input$move_ui$sqs_ids, {
    #   
    #   print(values$elements)
    #   
    #   print(unlist(input$move_ui$sqs_ids))
    #   print(input$move_ui$sqs_ids)
    #   
    # })
    
    
    #### Export Folders. ####
    
    
    output$export_folders_directory <- renderUI({
      path = parseDirPath(volumes, input$export_folders_directory)
      
      if (is.null(path)) {
        path = getwd()
      } else {
        if (length(path) == 0) {
          path = getwd()
        }
      }
      
      if (input$create_sub_folder) {
        if (nchar(input$sub_folder_name) != 0) {
          path = paste(path, input$sub_folder_name, sep="/")
        } else {
          path = paste(path, "app", sep="/")
        }
      }
      
      values$export_folders_directory = path
      
      tags$pre(values$export_folders_directory)
    })
    outputOptions(output, "export_folders_directory", suspendWhenHidden = FALSE)
    
    
    observeEvent(input$sub_folder_name, {
      updateTextInput(
        session = session,
        inputId = "project_name",
        value = input$sub_folder_name
      )
    })
    
    
    observeEvent(input$export_folders, {
      
      folder_paths = c()
      file_paths = c()
      
      if (input$create_sub_folder) {
        folder_paths = c(folder_paths, values$export_folders_directory)
      }

      for (folder in input$create_folders) {
        folder_paths = c(folder_paths, paste0(values$export_folders_directory, "/", folder))
      }
      
      if (input$create_as_rstudio_project) {
        file_paths = c(file_paths, paste0(values$export_folders_directory, "/", input$project_name, ".Rproj"))
      }
      
      values$export_folder_paths = folder_paths

      text = sprintf("<p>The following folders/files will be created:<p><br><pre>%s</pre>",
                     paste(
                       paste(folder_paths, collapse="\n"),
                       paste(file_paths, collapse="\n"),
                       sep="\n")
                    )
      text = sprintf("%s<br><p>Already exisiting folders/files with identical filenames will be overwritten.<p>", text)
      
      shinyalert(
        inputId = "export_folders_2",
        title = "Warning",
        text = text,
        type = "warning",
        closeOnEsc = TRUE,
        closeOnClickOutside = TRUE,
        html = TRUE,
        showConfirmButton = TRUE,
        showCancelButton = TRUE,
        confirmButtonText = "Create Folder Structure",
        cancelButtonText = "Cancel",
        size = "m",
        animation = TRUE,
        className = "shinyalert-with-scrollbar"
      )
      
    })
    
    
    observeEvent(input$export_folders_2, {
      if (input$export_folders_2) {
        
        for (i in 1:length(values$export_folder_paths)) {
          dir.create(values$export_folder_paths[i])
        }
        
        if (input$create_as_rstudio_project) {
          file_content = "
            Version: 1.0
            
            RestoreWorkspace: Default
            SaveWorkspace: Default
            AlwaysSaveHistory: Default
            
            EnableCodeIndexing: Yes
            UseSpacesForTab: Yes
            NumSpacesForTab: 2
            Encoding: UTF-8
            
            RnwWeave: Sweave
            LaTeX: pdfLaTeX
            
            BuildType: Package
            PackageUseDevtools: Yes
            PackageInstallArgs: --no-multiarch --with-keep.source
            PackageCheckArgs: --as-cran
            "
          
          file_path = paste0(values$export_folders_directory, "/", input$project_name, ".Rproj")
          cat(file_content, file=file_path)
        }
        
      }
    })
    
    
    #### Export Code. ####
    
    
    output$export_code_directory <- renderUI({
      path = parseDirPath(volumes, input$export_code_directory)
      
      if (is.null(path)) {
        path = getwd()
      } else {
        if (length(path) == 0) {
          path = getwd()
        }
      }
      
      values$export_code_directory = path

      tags$pre(values$export_code_directory)
    })
    outputOptions(output, "export_code_directory", suspendWhenHidden = FALSE)
    
    
    observeEvent(input$export_code, {
      
      if (input$sqs_page_type == "tagList") {
        file_paths = sprintf("%s/%s.R", values$export_code_directory, input$module_name)
      } else {
        if (input$multiple_files) {
          file_paths = c(
            paste0(values$export_code_directory, "/global.R"),
            paste0(values$export_code_directory, "/ui.R"),
            paste0(values$export_code_directory, "/server.R")
          )
        } else {
          filename = input$app_filename
          if (nchar(str_replace_all(filename, " ", "")) == 0) {
            filename = "app.R"
          } else {
            if (!str_detect("app.R", ".R$")) {
              filename = paste0(filename, ".R")
            }
          }
          file_paths = paste0(values$export_code_directory, "/", filename)
        } 
      }
      
      values$export_file_paths = file_paths
      
      text = sprintf("<p>Your code will be exported to:<p><br><pre>%s</pre>", 
                     paste(file_paths, collapse="\n"))
      text = sprintf("%s<br><p>Already exisiting files with identical filenames will be overwritten.<p>", text)

      shinyalert(
        inputId = "export_code_2",
        title = "Warning",
        text = text,
        type = "warning",
        closeOnEsc = TRUE,
        closeOnClickOutside = TRUE,
        html = TRUE,
        showConfirmButton = TRUE,
        showCancelButton = TRUE,
        confirmButtonText = "Export Code",
        cancelButtonText = "Cancel",
        size = "m",
        animation = TRUE,
        className = "shinyalert-with-scrollbar"
      )
      
    })
    
    
    observeEvent(input$export_code_2, {
      if (input$export_code_2) {
        global_code = .create_global_code(
          values$elements, values$arguments,
          input$add_documentation, input$remove_all, input$source_functions, input$source_modules
        )
        
        if (input$sqs_page_type == "tagList") {
          file_contents = values$module_code
        } else {
          if (input$multiple_files) {
            file_contents = c(
              global_code,
              values$ui_code,
              values$server_code
            )
          } else {
            file_contents = sprintf("%s\n\n\n%s\n\n%s\n\n%s",
                                    global_code, values$ui_code, values$server_code, 
                                    "runApp(list(ui=ui, server=server))")
          }
        }
        
        for (i in 1:length(values$export_file_paths)) {
          cat(file_contents[i], file=values$export_file_paths[i])
        }
        
      }
    })
    
    
    # Close App when tab or browser is closed.
    session$onSessionEnded(function() {
      session$sendCustomMessage("stop_addin", NULL)
      stopApp()
    })
    
    
    observeEvent(input$stop_addin_button, {
      stopApp()
    })

  }
  
  return(server)
  
}