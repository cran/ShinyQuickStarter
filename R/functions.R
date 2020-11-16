#### General Functions. ####

## Determines the correct path for the filename in the installed ShinyQuickStarter package.
##
## @param filename Name of the file.
##
## @return path to the filename in the ShinyQuickStarter package.
.get_system_file_path <- function(filename) {
  if (filename == "img") {
    return(system.file("extdata", "img", package = "ShinyQuickStarter"))
  } else {
    return(system.file("extdata", "templates", filename, package = "ShinyQuickStarter"))
  }
}


## Determines the new index of the hidden ids.
##
## @param ids Current hidden ids in the navigation, module or navigation_module table.
##
## @return The highest current id.
.get_hidden_id <- function(ids) {
  ids = unique(unlist(str_split(ids, "_")))
  ids = ids[!ids %in% c("Navigation", "Module", "Navigation_Module")]
  ids = as.integer(ids)

  if (length(ids) == 0) {
    return(0)
  } else {
    return(max(ids))
  }
}


## Creates a named list for the SelectInput with all navigation elements that are on the lowest
## level. The names show the navigation position and id, whereas the value is just the navigation id.
##
## @param navigation The current navigation data.table.
##
## @return A named list.
.get_navigation_paths <- function(navigation) {

  # Assumes that there are no gaps in the navigation positions and the data.table is in correct order.

  texts = c()

  if (nrow(navigation) > 0) {
    for (index in 1:nrow(navigation)) {

      position = str_split(navigation$Navigation_Position[index], "\\.")[[1]]

      if (index == 1) {
        text = c(navigation$Title[1])
      } else {
        if (length(previous) == length(position)) {
          # Same level - replace the last element.
          text = c(text[1:length(text)-1], navigation$Title[index])
        } else if (length(previous) < length(position)) {
          # Deeper level - add to the end (can only always go one layer deeper).
          text = c(text, navigation$Title[index])
        } else if (length(previous) > length(position)) {
          # Higher level - remove the n last elements (can go up by multiple layers)
          # and replace the last element.
          text = c(text[1:length(position)-1], navigation$Title[index])
        }
      }

      texts = c(texts, paste(navigation$Navigation_Position[index], paste(text, collapse=" - "), sep=" "))
      previous = position

    }
  }

  return(texts)

}



#### Step 1: Project Structure. ####

## Creates the relevant paths of all the folders and files that should be created and that will
## be used in further functions.
##
## @params checkbox_create_in_current_directory True if the the project structure will be created
## in the current directory.
## @params directory_path Path to the directory where the project structure will be created. Only
## relevant if checkbox_create_in_current_directory is False.
## @params checkbox_create_project_folder True if a new project sub folder should be created.
## @params text_project_folder_name Name of the project folder.
## @params checkbox_rstudio_project True if the project should setup a RStudio file.
## @params checkbox_modules True if modules should be used.
## @params checkbox_multiple_files True if separate global.R, ui.R, server.R should be created.
## @params checkbox_custom_css_js True if a custom css and js file should be created.
##
## @return A named list with the paths to the directory, the project folder, the addin data. And
## also all absolute and relative paths of the files that should be created.
.get_paths <- function(checkbox_create_in_current_directory,
                       directory_path,
                       checkbox_create_project_folder,
                       text_project_folder_name,
                       checkbox_rstudio_project,
                       checkbox_modules,
                       checkbox_multiple_files,
                       checkbox_custom_css_js) {

  # Determine the folders and files to be created based on the user settings.
  if (checkbox_create_in_current_directory) {
    directory_path = getwd()
  }

  files = c()

  if(checkbox_rstudio_project) {
    files = append(files, paste0(text_project_folder_name, ".Rproj"))
  }

  files = append(files, "app")

  if (checkbox_multiple_files) {
    files = append(files, c("app/global.R", "app/ui.R", "app/server.R"))
  } else {
    files = append(files, "app/app.R")
  }

  files = append(files, "app/www")

  if (checkbox_custom_css_js) {
    files = append(files, c("app/www/custom.css", "app/www/custom.js"))
  }

  files = append(files, "app/functions")

  if (checkbox_modules) {
    files = append(files, "app/modules")
  }

  files = append(files, "data")


  # New sub-folder for the project in the directory?
  if (checkbox_create_project_folder) {
    files = paste(text_project_folder_name, files, sep="/")
    files = append(text_project_folder_name, files)

    project_path = paste(directory_path, text_project_folder_name, sep="/")
  } else {
    project_path = directory_path
  }

  full_paths = paste(directory_path, files, sep="/")

  return(list(
    "directory" = directory_path,
    "project" = project_path,
    "addin_data" = paste(project_path, ".ShinyQuickStarter", sep="/"),
    "full" = full_paths,
    "short" = files
  ))

}



## Creates the project structure for the shiny app.
##
## @param paths Named list from the .get_paths function.
.create_folder_structure <- function(paths) {

  # TODO: could possibly make problems with folders in directory path with dots in names.
  folders = paths[["full"]][!str_detect(paths[["full"]], "\\.")]
  files = paths[["full"]][str_detect(paths[["full"]], "\\.")]

  # Creating basic folders.
  for (folder in folders) {
    if (!file.exists(folder)) {
      dir.create(folder)
    }
  }

  # Copy logo images. (Only for internal use.)
  if (code_templates$Condition[code_templates$Variable == "logo_import_header"]) {
    if (!file.exists(paste(paths[["project"]], "app/www/logo", sep="/"))) {
      dir.create(paste(paths[["project"]], "app/www/logo", sep="/"))
    }

    filenames = c("Industrie_4.0_Werkstatt.jpg", "THD.jpg", "TCG.jpg", "EFRE.jpg")

    current_files = paste(.get_system_file_path("img"), filenames, sep="/")

    new_files = paste(paths[["project"]], "app/www/logo", filenames, sep="/")

    file.copy(from=current_files, to=new_files,
              overwrite = TRUE, recursive = FALSE, copy.mode = TRUE)
  }

  for (path in files) {
    if (endsWith(path, "Rproj")) {
      text = read_file(.get_system_file_path("template_rproj.txt"))
    } else {
      text = ""
    }
    text = enc2utf8(text)
    con = file(path, open = "w", encoding = "UTF-8")
    writeLines(text, con = con)
    close(con)
  }

}



## Updates the folder structure.
##
## @param paths Named list from the .get_paths function.
## @param delete Absolute paths of the folder/files that will be deleted.
## @param create Absolute paths of the folder/files that will be created.
.update_folder_structure <- function(paths, delete, create) {
  paths[["full"]] = create
  .create_folder_structure(paths)
  .delete_folder_structure(delete)
}



## Deletes the project folder recursive.
##
## @param directory_path Name of the directory_path where the project and all subsequent
## folders and files should be deleted
.delete_folder_structure <- function(paths) {
  unlink(paths, recursive = TRUE)
}



## Checks if the existing project structure is consistent with the settings.
##
## @param paths Named list from the .get_paths function.
## @param current_settings All current settings from the input_fields reactive.
## @param navigation The navigation data.table.
## @param module The module data.table.
## @param navigation_module The navigation_module data.table.
##
## @return A named list with boolean indicators if the project structure can be created, updated,
## deleted, what files will be created/deleted in the update, if settings can be imported and if
## the current settings are matching with the saved settings.
.check_project_options <- function(paths, current_settings=NULL, checkbox_create_project_folder=FALSE,
                                   navigation=NULL, module=NULL, navigation_module=NULL) {

  check = list("create_possible" = FALSE,
               "import_possible" = FALSE,
               "settings_matching" = FALSE,
               "update_possible" = FALSE,
               "update_create" = c(),
               "update_delete" = c(),
               "delete_possible" = FALSE)

  # Check if project path does exist.
  if (file.exists(paths[["project"]])) {
    check[["delete_possible"]] = TRUE

    # Check if all needed files exist.
    paths_needed = paths[["full"]]

    paths_existing = list.files(paths[["project"]], recursive=TRUE, include.dirs=TRUE, all.files=TRUE, full.names=TRUE)
    if (checkbox_create_project_folder) {
      paths_existing = append(paths[["project"]], paths_existing)      
    }
    paths_existing = paths_existing[!str_detect(paths_existing, "modules/.*")]
    paths_existing = paths_existing[!str_detect(paths_existing, "\\.ShinyQuickStarter.*")]
    paths_existing = paths_existing[!str_detect(paths_existing, "logo")]

    if (!all(all(paths_needed %in% paths_existing), all(paths_existing %in% paths_needed))) {
      check[["update_possible"]] = TRUE
      check[["update_create"]] = paths_needed[!paths_needed %in% paths_existing]
      check[["update_delete"]] = paths_existing[!paths_existing %in% paths_needed]
    }
  } else {
    check[["create_possible"]] = TRUE
  }

  # Check if .ShinyQuickStarter does exist in project path.
  if (file.exists(paths[["addin_data"]])) {
    check[["import_possible"]] = TRUE

    if (!is.null(current_settings)) {
      # Check if exported/saved settings are the same as the current settings
      saved_settings = read_lines(paste(paths[["addin_data"]], "settings.txt", sep="/"))
      saved_settings = str_split_fixed(saved_settings, ":", 2)
      saved_settings = as.data.frame(saved_settings, stringsAsFactors=FALSE)
      colnames(saved_settings) = c("name", "value")
      
      current_settings = stack(lapply(current_settings, as.character))
      colnames(current_settings)[colnames(current_settings) == "values"] = "value"
      colnames(current_settings)[colnames(current_settings) == "ind"] = "name"
      current_settings$name = as.character(current_settings$name)
      
      comparision = inner_join(saved_settings, current_settings, by="name", suffix=c(".current", ".saved"))
      
      if (all(comparision$value.current == comparision$value.saved)) {
        check[["settings_matching"]] = TRUE
        
        if (current_settings$value[current_settings$name == "checkbox_modules"]) {
          filenames = c("navigation.RDS", "module.RDS", "navigation_module.RDS")
        } else {
          filenames = c("navigation.RDS")
        }
        
        for (filename in filenames) {
          if (!is.null(get(str_replace(filename, ".RDS", "")))) {
            if (file.exists(paste(paths[["addin_data"]], filename, sep="/"))) {
              
              saved = as.data.table(readRDS(paste(paths[["addin_data"]], filename, sep="/")))
              current = as.data.table(get(str_replace(filename, ".RDS", "")))
              
              if (is.logical(all.equal(current, saved))) {
                check[["settings_matching"]] = TRUE
              } else {
                check[["settings_matching"]] = FALSE
                break
              }
            } else {
              check[["import_possible"]] = FALSE
              check[["settings_matching"]] = FALSE
              break
            }
          } else {
            check[["import_possible"]] = FALSE
            check[["settings_matching"]] = FALSE
            break
          }
        }
      }
    } else {
      check[["settings_matching"]] = FALSE
    }
  }

  return(check)

}



## Exports the settings of the addin.
##
## @param paths Named list from the .get_paths function.
## @param input_fields
## @param navigation
## @param module
## @param navigation_module
.export_settings <- function(paths, input_fields, navigation, module, navigation_module) {

  if (!file.exists(paste(paths[["project"]], ".ShinyQuickStarter", sep="/"))) {
    dir.create(paste(paths[["project"]], ".ShinyQuickStarter", sep="/"))
  }

  settings = ""
  for (name in names(input_fields)) {
    if (str_detect(name, c("select_|text_|colour_|checkbox_"))) {
      settings = c(settings, paste0(name, ":", input_fields[[name]]))
    }
  }
  settings = settings[2:length(settings)]
  settings = paste(settings, collapse="\n")
  cat(settings, file = paste(paths[["project"]], ".ShinyQuickStarter/settings.txt", sep="/"))

  saveRDS(navigation, file = paste(paths[["project"]], ".ShinyQuickStarter/navigation.RDS", sep="/"))

  if (!input_fields[["checkbox_modules"]]) {
    module = module[0,]
    navigation_module = navigation_module[0,]
  }

  saveRDS(module, file = paste(paths[["project"]], ".ShinyQuickStarter/module.RDS", sep="/"))
  saveRDS(navigation_module, file = paste(paths[["project"]], ".ShinyQuickStarter/navigation_module.RDS", sep="/"))

}



## Imports the settings of the addin. The imported settings are used to update the Inputs
## at the start of the addin.
##
## @param paths Named list from the .get_paths function.
##
## @return A list with the imported settings of the input fields and the navigation, module
## and navigation_module tables.
.import_settings <- function(paths) {

  settings = read_lines(paste(paths[["project"]], ".ShinyQuickStarter/settings.txt", sep="/"))
  settings = str_split_fixed(settings, ":", 2)

  settings = as.data.frame(settings, stringsAsFactors=FALSE)
  colnames(settings) = c("name", "value")

  navigation = readRDS(paste(paths[["project"]], ".ShinyQuickStarter/navigation.RDS", sep="/"))

  module = readRDS(paste(paths[["project"]], ".ShinyQuickStarter/module.RDS", sep="/"))
  navigation_module = readRDS(paste(paths[["project"]], ".ShinyQuickStarter/navigation_module.RDS", sep="/"))

  return(list("settings" = settings, "navigation" = navigation,
              "module" = module, "navigation_module" = navigation_module))

}



#### Step 2: Files. ####



## Creates the code for all files based on the code templates and the settings in the addin.
##
## @param input_fields
## @param navigation A data.table with the navigation data.
##
## @return A data table with the Filename and the Code of the corresponding files.
.create_code <- function(input_fields, navigation) {

  # Assign input variables from list.
  for (name in names(input_fields)) {
    assign(name, input_fields[[name]])
  }

  code = data.table(
    Filename = c("global.R", "ui.R", "server.R", "custom.css", "custom.js"),
    Code = c(read_file(.get_system_file_path("template_global.R")),
             read_file(.get_system_file_path("template_ui.R")),
             read_file(.get_system_file_path("template_server.R")),
             read_file(.get_system_file_path("template_custom.css")),
             read_file(.get_system_file_path("template_custom.js")))
  )

  if (!eval(parse(text="checkbox_custom_css_js"))) {
    code = code[code$Filename %in% c("global.R", "ui.R", "server.R"),]
  }

  # Replace placeholders (e. g. ###text_title###) in the template based on some conditions.
  # The placeholders, conditions and replacements are imported from an csv-file for easy
  # expandability.
  for (filename in unique(code_templates$Filename)) {

    for (variable in code_templates$Variable[code_templates$Filename == filename]) {

      pattern = paste0("###", variable, "###")
      replacement = code_templates$Code[code_templates$Variable == variable & code_templates$Filename == filename]
      condition = code_templates$Condition[code_templates$Variable == variable & code_templates$Filename == filename]

      if (replacement != "") {

        # Create replacement with a custom function if necessary (e. g. sidebar, tabItems).
        if (str_detect(replacement, "custom_function: ")) {
          function_code = str_replace(replacement, "custom_function: ", "")
          replacement = eval(parse(text = function_code))
        }

        # Fill placeholders in the replacement itself (e. g. text_title replacement in
        # text_title replacement).
        further_replacements = str_extract_all(replacement, "###.*###")[[1]]
        further_replacements = unique(further_replacements)

        for (further_replacement in further_replacements) {
          replacement = str_replace_all(replacement, further_replacement,
                                        get(str_replace_all(further_replacement, "#", "")))
        }

        # Between two UI elements needs to be a comma.
        if (filename == "ui.R") {
          replacement = paste0(replacement, ",\n")
        } else {
          replacement = paste0(replacement, "\n\n")
        }

        # If the user opted out of some setting, the placeholder will be removed.
        if (!eval(parse(text = condition))) {
          replacement = ""
        }

      } else {
        replacement = ""
      }

      code$Code[code$Filename == filename] = str_replace_all(code$Code[code$Filename == filename], pattern, replacement)

    }

  }

  if (!get("checkbox_modules")) {
    code$Code[code$Filename == "server.R"] =
      str_replace(code$Code[code$Filename == "server.R"], "###server_code###", "")
  }

  return(code)

}



## Prepares the code for exporting it and the display in the Addin.
##
## @param select_filename The filename of the code that should be prepared.
## @param code The data.frame with all the generated codes.
##
## @return text The prepared code.
.prepare_code <- function(select_filename, code) {

  if (select_filename == "app.R") {

    # Concat global.R, ui.R and server.R to app.R.
    text = paste0(code$Code[code$Filename == "global.R"], "\n\n\n",
                  "app <- shinyApp(\n\n\t",
                  code$Code[code$Filename == "ui.R"], ",\n\n\n\n\n",
                  code$Code[code$Filename == "server.R"], ")\n\n\n",
                  "#runApp(app)")

  } else {

    text = code$Code[code$Filename == select_filename]

  }

  if (!(select_filename %in% c("custom.css", "custom.js"))) {

    # Style code. (Windows line breaks \r need to be removed for styler.)
    text = str_replace_all(text, "\r", "")
    #text = style_text(text)
    text = paste(text, collapse="\n")

    # Remove instances in ui where a comma is at the end of an element without a next element.
    text = str_replace_all(text, "\n\n[\n]+", "\n\n")
    text = str_replace_all(text, "\\,[\n\t\r ]*\\)", ")\n")

    text = style_text(text, scope="line_breaks")
    text = paste(text, collapse="\n")

  }

  text = str_replace_all(text, "\n\n\n", "\n\n")

  return(text)

}



## Creates the sidebar for ShinyDashboard.
##
## @param navigation A data.frame with the columns Navigation_Position, Navigation_ID and Title.
##
## @return text The code of the navigation ui part.
.create_sidebar <- function(navigation) {

  navigation = navigation[order(navigation$Navigation_Position),]
  navigation$Layer = nchar(navigation$Navigation_Position) - nchar(gsub("\\.", "", navigation$Navigation_Position))

  sidebarMenu_code = "sidebarMenu(id = 'tabs'###new_menu_item###)"
  menuItem_code = "\n\n\t, menuItem('%s', tabName = '%s'###new_menu_item###)###new_menu_item###"

  text = sidebarMenu_code

  if (nrow(navigation) != 0) {
    for (index in 1:nrow(navigation)) {

      if (index == 1) {

        text = stri_replace_first(
          str = text,
          replacement = paste(sprintf(menuItem_code, navigation$Title[index], navigation$Navigation_ID[index]),
                              "###new_menu_item###"), regex = "###new_menu_item###")

      } else {

        if (navigation$Layer[index] == navigation$Layer[index-1]) {
          # Stays on the same layer.
          # Replace first with nothing. Then replace first with menuItem.
          text = stri_replace_first(
            str = text,
            replacement = "",
            regex = "###new_menu_item###"
          )
          text = stri_replace_first(
            str = text,
            replacement = paste(sprintf(menuItem_code, navigation$Title[index], navigation$Navigation_ID[index]),
                                "###new_menu_item###"),
            regex = "###new_menu_item###"
          )
        } else if (navigation$Layer[index] > navigation$Layer[index-1]) {
          # Goes one layer deeper.
          text = stri_replace_first(
            str = text,
            replacement = paste(",\n\tstartExpanded = TRUE", sprintf(menuItem_code, navigation$Title[index], navigation$Navigation_ID[index]),
                                "###new_menu_item###"),
            regex = "###new_menu_item###"
          )
        } else if (navigation$Layer[index] < navigation$Layer[index-1]) {
          # Goes one or more layers higher.
          for (index_higher in 0:(navigation$Layer[index-1] - navigation$Layer[index])) {
            text = stri_replace_first(
              str = text,
              replacement = "",
              regex = "###new_menu_item###"
            )
          }
          text = stri_replace_first(
            str = text,
            replacement = paste(sprintf(menuItem_code, navigation$Title[index], navigation$Navigation_ID[index]), "###new_menu_item###"),
            regex = "###new_menu_item###"
          )
        }

      }

      text = gsub("(###new_menu_item###( )?)*", "\\1", text)

    }
  }

  # Deletes all unused placeholders.
  text = gsub("###new_menu_item###", "", text)

  return(text)

}



## Creates the tabItems for ShinyDashboard.
##
## @param navigation A data.frame with the columns Navigation_Position, Navigation_ID and Title.
##
## @return text The code of the tabItems ui part.
.create_tab_items <- function(navigation) {

  navigation = navigation[order(navigation$Navigation_Position),]
  navigation$Layer = nchar(navigation$Navigation_Position) - nchar(gsub("\\.", "", navigation$Navigation_Position))

  if (nrow(navigation) != 0) {
    tabItems_code = "fluidRow(\n\n\ttabItems(###new_tab_item###))"
    tabItem_code = "\n\n\t #%s.\n\ntabItem(tabName = '%s'),\n###new_tab_item###"

    text = tabItems_code
    section_names = .get_navigation_paths(navigation)

    for (index in 1:nrow(navigation)) {

      text = stri_replace_first(
        str = text,
        replacement = paste(sprintf(tabItem_code, section_names[index], navigation$Navigation_ID[index]), "###new_tab_item###"),
        regex = "###new_tab_item###"
      )

      if (index == nrow(navigation)) {
        text = gsub("###new_tab_item###", "", text)
      }

    }
  } else {
    text = ""
  }

  return(text)

}



#### Step 3: Navigation. ####


## Changes a string into a valid navigation id.
##
## @param title A string.
##
## @return A valid navigation id.
.title_to_valid_id <- function(title) {

  # Suggestion for Navigation_ID based on Navigation_Title.
  id = tolower(title)
  id = str_replace_all(id, "[:punct:]", "_")
  id = str_replace_all(id, " ", "_")
  # TODO: maybe also replace umlaute.

  return(id)
}


## Identifies if there are gaps between the navigation positions.
##
## @param navigation A data.table.
##
## @return A character string that show the gaps in the navigation positions.
.check_navigation_position <- function(navigation) {

  errors = ""
  positions = sort(navigation$Navigation_Position)

  # Empty table.
  if (length(positions) == 0) {
    return(NULL)
  }

  # Case 1: Navigation does not start at 1.
  if (!any(positions == "1")) {
    errors = paste(errors, "Navigation does not start at the Position 1.", sep="\n")
  }

  if (length(positions) == 1) {
    if (errors == "") {
      return(NULL)
    }
  }

  # Case 2: Gap between navigation points.
  positions_splitted = str_split(positions, "\\.")

  previous = positions_splitted[[1]]
  for (index in 2:length(positions_splitted)) {
    if (length(positions_splitted[[index]]) == length(previous)) {
      # Same layer.
      if (as.integer(tail(positions_splitted[[index]], 1)) - 1 == as.integer(tail(previous, 1))) {
        # Directly following.
      } else {
        errors = paste(errors,
                       paste0("Gap between ", positions[[index-1]], " and ", positions[[index]], "."),
                       sep = "\n")
      }
    } else if (length(positions_splitted[[index]]) == length(previous) + 1) {
      # One layer deeper.
      if (tail(positions_splitted[[index]], 1) == "1") {
        # Deeper layer starts with 1 at the end.
        if (all(previous == positions_splitted[[index]][1:length(previous)])) {
          # Prefix matching.
        } else {
          errors = paste(errors,
                         paste0("Gap between ", positions[[index-1]], " and ", positions[[index]], "."),
                         sep = "\n")
        }
      } else {
        errors = paste(errors,
                       paste0("Gap between ", positions[[index-1]], " and ", positions[[index]], "."),
                       sep = "\n")
      }
    } else if (length(positions_splitted[[index]]) > length(previous) + 1) {
      # Multiple layers deeper.
      errors = paste(errors,
                     paste0("Gap between ", positions[[index-1]], " and ", positions[[index]], "."),
                     sep = "\n")
    } else if (length(positions_splitted[[index]]) < length(previous)) {
      # One layer higher.
      layer_diff = length(previous) - length(positions_splitted[[index]])

      if (as.integer(previous[length(previous) - layer_diff]) + 1 ==
          as.integer(tail(positions_splitted[[index]], 1))) {
        # Upper level directly following.
      } else {
        errors = paste(errors,
                       paste0("Gap between ", positions[[index-1]], " and ", positions[[index]], "."),
                       sep = "\n")
      }
    }
    previous = positions_splitted[[index]]
  }

  if (errors == "") {
    return(NULL)
  } else {
    return(errors)
  }

}



# A column of delete buttons for each row in the data frame for the first column
#
# @param df A data.frame.
# @param onclick An id for the delete/edit buttons.
# @param hidden_columns Index of columns that will be hidden.
#
# @return A DT::datatable with escaping turned off that has the delete buttons in the first column and \code{df} in the other
.buttons_in_dt <- function(df, onclick, hidden_columns=c(), ...) {

  # Function to create action buttons as string.
  create_buttons = function(index) {
    paste(
      as.character(
        actionButton(
          paste("delete", index, sep="_"),
          label = NULL,
          icon = icon("trash", "fa-0.5x"),
          onclick = paste('Shiny.setInputValue(\"button_', onclick, '_delete',
                          '\", this.id, {priority: "event"})', sep="")
        )
      ),
      as.character(
        actionButton(
          paste("edit", index, sep="_"),
          label = NULL,
          icon = icon("edit", "fa-0.5x"),
          onclick = paste('Shiny.setInputValue(\"button_', onclick, '_edit_form',
                          '\", this.id, {priority: "event"})', sep="")
        )
      ),
      sep="  "
    )

  }

  buttons = unlist(lapply(seq_len(nrow(df)), create_buttons))

  # Return a data table with the buttons.
  DT::datatable(
    cbind(" " = buttons, df),
    escape = FALSE,
    rownames = FALSE,
    selection = "none",
    options = list(
      columnDefs = list(
        # Unsortable columns.
        list(targets = c(0), sortable = FALSE),
        # Hidden columns.
        list(targets = c(hidden_columns), visible = FALSE),
        ...
      ),
      dom = "t",
      pageLength = 100
    )
  )
}


# Determines a names list for the selectInput for the selection of navigation items.
# In the Addin the names get displayed to the user with an indicator of the navigation position
# and the navigation id.
#
# @param navigation A data.table.
#
# @return A named list for the selectInput.
.get_list_for_navigation_select <- function(navigation) {

  # Identify lowest navigation levels.
  navigation = navigation[order(navigation$Navigation_Position),]
  x = sort(navigation$Navigation_Position)
  x = str_split(x, "\\.")

  lowest = c()

  if (nrow(navigation) > 0) {
    for (index in 1:length(x)) {
      if (index != length(x)) {
        if (length(x[[index]]) < length(x[[index+1]])) {
          lowest = c(lowest, FALSE)
        } else {
          lowest = c(lowest, TRUE)
        }
      }
    }
  }

  lowest = c(lowest, TRUE)

  # Create named list for selectInput.
  table = navigation[lowest, c("Navigation_ID", "Navigation_Position", "Title")]
  table$Title = paste0("(", table$Navigation_Position, ") ", table$Navigation_ID)
  choices = as.list(table$Navigation_ID)
  names(choices) = table$Title

  return(choices)
}


# Creates the code for all defined modules from a code template.
#
# @param code
# @param navigation
# @param module
# @param navigation_module
# @param select_suffix_style
#
# @return
.create_module_code <- function(code, navigation, module, navigation_module, select_suffix_style) {

  template_module = read_file(.get_system_file_path("template_module.R"))

  if (nrow(module) != 0) {

    # Create the code for the modules.
    module_code = data.table(
      Filename = module$Module_ID,
      Code = rep(template_module, nrow(module))
    )

    module_code$Code = str_replace_all(module_code$Code, "###text_module_name###", module_code$Filename)
    suffix_styles = str_split(select_suffix_style, "/")[[1]]

    for (index in 1:nrow(module_code)) {

      temp_code = module_code$Code[index]

      temp_code = str_replace_all(temp_code, "###text_module_name###", module_code$Filename[index])
      temp_code = str_replace(temp_code, "###select_suffix_style###", suffix_styles[1])
      temp_code = str_replace(temp_code, "###select_suffix_style###", suffix_styles[2])

      if (module$Return[index]) {
        replacement = "return(\n\tlist(\n\t\tvar1 = reactive(input$var1)\n\t)\n)"
      } else {
        replacement = ""
      }
      temp_code = str_replace(temp_code, "###checkbox_return###", replacement)

      module_code$Code[index] = temp_code

    }

    module_code$Filename = paste0(module_code$Filename, ".R")

    # Combine codes to one data table.
    codes = list(code, module_code)
    code = rbindlist(codes)

  }

  # Append module code for ui.
  code = .append_modules_to_ui(code, navigation, module, navigation_module, select_suffix_style)
  code = .append_modules_to_server(code, navigation, module, navigation_module, select_suffix_style)

  return(code)

}


# Appends the module dependent code to the ui.
#
# @param code
# @param navigation
# @param module
# @param navigation_module
# @param select_suffix_style
#
# @return
.append_modules_to_ui <- function(code, navigation, module, navigation_module, select_suffix_style) {

  navigation_items = unique(navigation_module$Navigation_ID)

  ui_code = code$Code[code$Filename == "ui.R"]
  suffix_style = str_split(select_suffix_style, "/")[[1]][1]

  for (item in navigation_items) {

    pattern = paste0("tabItem\\(tabName = \'", item, "\'")

    module_ids = navigation_module$Module_ID[navigation_module$Navigation_ID == item]
    module_instance_ids = navigation_module$Module_Instance_ID[navigation_module$Navigation_ID == item]

    replacements = paste0(module_ids, suffix_style, "(\"", module_instance_ids, "\")")
    replacement = paste(replacements, collapse=",\n")
    replacement = paste0(pattern, ",\n", replacement)

    ui_code = str_replace(ui_code, pattern, replacement)

  }

  code$Code[code$Filename == "ui.R"] = ui_code

  return(code)

}


# Appends the module dependent code to the server.
#
# @param code
# @param navigation
# @param module
# @param navigation_module
# @param select_suffix_style
#
# @return
.append_modules_to_server <- function(code, navigation, module, navigation_module, select_suffix_style) {

  table = inner_join(navigation_module, module, by = c("Hidden_Module_ID", "Module_ID"))

  section_names = .get_navigation_paths(navigation)
  server_code = code$Code[code$Filename == "server.R"]
  suffix_style = str_split(select_suffix_style, "/")[[1]][2]

  pattern = "###server_code###"
  complete_replacement = ""

  for (index_navigation in 1:nrow(navigation)) {

    item = navigation$Navigation_ID[index_navigation]

    module_ids = table$Module_ID[table$Navigation_ID == item]
    module_instance_ids = table$Module_Instance_ID[table$Navigation_ID == item]
    return = table$Return[table$Navigation_ID == item]

    if (length(module_instance_ids) != 0) {

      replacements = ""

      for (index in 1:length(module_ids)) {
        text = paste0(module_ids[index], suffix_style, "(\"", module_instance_ids[index], "\")")
        if (return[index]) {
          text = paste0(module_instance_ids[index], "_vars = ", text)
        }
        replacements = c(replacements, text)
      }

      replacement = paste(replacements, collapse="\n")
      replacement = paste0("# ", section_names[index_navigation], ".\n", replacement, "\n")

    } else {

      replacement = ""

    }

    complete_replacement = paste0(complete_replacement, "\n", replacement, "\n")

  }

  server_code = str_replace(server_code, pattern, complete_replacement)
  code$Code[code$Filename == "server.R"]  = server_code

  return(code)

}


# Exports the generated code to the corresponding files.
#
## @param paths Named list from the .get_paths function.
# @param checkbox_multiple_files True if global.R, ui.R and a server.R will be created.
# @param code A data.frame with the code in the files.
.export_all_code <- function(paths, checkbox_multiple_files, code) {

  files = code$Filename
  if (!checkbox_multiple_files) {
    files = c("app.R", files[!files %in% c("global.R", "ui.R", "server.R")])
  }

  withProgress(message = "Exporting code.", value = 0, {

    index = 1
    for (file in files) {

      if (file %in% c("app.R", "global.R", "ui.R", "server.R")) {
        path = paste(paths[["project"]], "app", file, sep="/")
      } else if (file %in% c("custom.css", "custom.js")) {
        path = paste(paths[["project"]], "app", "www", file, sep="/")
      } else {
        path = paste(paths[["project"]], "app", "modules", file, sep="/")
      }

      text = .prepare_code(file, code)

      # Create Connection with UTF-8 encoding.
      text = enc2utf8(text)
      con = file(path, open = "w", encoding = "UTF-8")
      writeLines(text, con = con)
      close(con)

      # Increment the progress bar, and update the detail text.
      setProgress(index/length(files), detail = file)
      index = index + 1

    }

  })

}
