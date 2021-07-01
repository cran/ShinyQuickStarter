## Generates the HTML for updating the arguments of the highlighted ui element.
##
## @param element highlighted element
## @param df data.table with arguments of highlighted element
##
## @return HTML for options
.ui_options_to_tagList <- function(element, df) {
  uis1 = c()

  # Create options for ui function.
  ui_options = df[df$part == "ui",]
  if (nrow(ui_options) != 0) {
    for (index in 1:nrow(ui_options)) {
      ui = NULL
      
      if (ui_options$ui[index] == "textInput") {
        ui = .create_option_textInput(ui_options, index)
      } else if (ui_options$ui[index] == "checkboxInput") {
        ui = .create_option_checkboxInput(ui_options, index)
      } else if (ui_options$ui[index] == "selectInput") {
        ui = .create_option_selectInput("ui", ui_options, index)
      } else if (ui_options$ui[index] == "numericInput") {
        ui = .create_option_numericInput(ui_options, index)
      } else if (ui_options$ui[index] == "pickerInput") {
        ui = .create_option_pickerInput(ui_options, index)
      } else if (ui_options$ui[index] == "selectizeInput") {
        ui = .create_option_selectizeInput(ui_options, index)
      } else if (ui_options$ui[index] == "colorInput") {
        ui = .create_option_colorInput(ui_options, index)
      }
      
      ui = sprintf("div(class = 'row',
                        column(width = 4, %s),
                        column(width = 8,
                        div(class = 'sqs_validation', '%s'), 
                        div(class = 'sqs_description', HTML('%s'))
                      )
                   )",
                   ui, "", ui_options$description[index])
      uis1 = c(uis1, ui)
    }
  }
  
  if (length(uis1) > 0) {
    uis1 = c(sprintf("HTML('<h3>Options for <code>%s</code></h3>')", unique(ui_options$function_name)), uis1)
    
    excluded_arguments = arguments_excluded$argument[arguments_excluded$function_name == element$ui_function]
    if (length(excluded_arguments) > 0) {
      excluded_arguments = paste(excluded_arguments, collapse=", ")
      uis1 = c(uis1, sprintf("HTML('<p>Excluded arguments: <i>%s</i></p>')", excluded_arguments))
    }
    
    uis1 = paste(uis1, collapse=",")
    uis1 = sprintf("tagList(%s)", uis1)
  } else {
    uis1 = "tagList()"
  }

  return(uis1)
}


## Generates the HTML for updating the arguments of the highlighted ui element.
##
## @param element highlighted element
## @param df data.table with arguments of highlighted element
##
## @return HTML for options
.server_options_to_tagList <- function(element, df, single_quotes=TRUE) {
  uis2 = c()
  
  # Create options for server function - only for outputs.
  server_functions = ui_server$server_function[
    ui_server$ui_function %in% unique(df$function_name[df$part == "ui"])]
  
  if (length(server_functions) > 0) {
    # Header.
    uis2 = sprintf('HTML("<h3>Options for <code>%s</code></h3>")', server_functions[1])
    
    # Selection of expr.
    choice = server_expr$name[server_expr$ui_function == element$ui_function &
                                server_expr$server_function == element$server_function]
    
    ui = sprintf('selectInput(inputId = "sqs_option_server_expr", label = "expr",
                 choices = %s, selected = %s)',
                 .choices_to_string(choices_list=choice, with_NULL=FALSE),
                 df$value[df$part == "server" & df$argument == "expr"])
    uis2 = c(uis2, ui)
    
    # Server Options.
    # Default expr.
    exprs = server_expr[server_expr$ui_function == element$ui_function &
                          server_expr$server_function == element$server_function]
    
    for (index in 1:nrow(exprs)) {
      new_uis2 = sprintf("conditionalPanel(condition=\"input.sqs_option_server_expr==\'%s\'\", pre(\"%s\"))",
                         exprs$name[index], gsub('(")+', '"', exprs$expr[index]))
      uis2 = c(uis2, new_uis2)
    }
    
    # Other options.
    server_options = df[df$part == "server" & df$argument != "expr",]
    if (nrow(server_options) != 0) {
      for (index in 1:nrow(server_options)) {
        ui = NULL
        
        if (server_options$ui[index] == "textInput") {
          ui = .create_option_textInput(server_options, index)
        } else if (server_options$ui[index] == "checkboxInput") {
          ui = .create_option_checkboxInput(server_options, index)
        } else if (server_options$ui[index] == "selectInput") {
          ui = .create_option_selectInput("server", server_options, index)
        } else if (server_options$ui[index] == "numericInput") {
          ui = .create_option_numericInput(server_options, index)
        } else if (server_options$ui[index] == "pickerInput") {
          ui = .create_option_pickerInput(server_options, index)
        } else if (server_options$ui[index] == "selectizeInput") {
          ui = .create_option_selectizeInput(server_options, index)
        }
        
        ui = sprintf("div(class = 'row',
                        column(width = 4, %s),
                        column(width = 8,
                        div(class = 'sqs_validation', '%s'), 
                        div(class = 'sqs_description', HTML('%s'))
                      )
                   )",
                     ui, "", server_options$description[index])
        uis2 = c(uis2, ui)
      }
    }
    
  }
  
  if (length(uis2) > 0) {
    excluded_arguments = arguments_excluded$argument[arguments_excluded$function_name == element$server_function]
    if (length(excluded_arguments) > 0) {
      excluded_arguments = paste(excluded_arguments, collapse=", ")
      uis2 = c(uis2, sprintf("HTML('<p>Excluded arguments: <i>%s</i></p>')", excluded_arguments))
    }
    
    uis2 = paste(uis2, collapse=",")
    uis2 = sprintf("tagList(%s)", uis2)
  } else {
    uis2 = "tagList()"
  }

  return(uis2)
}


## Creates the HTML for an option that can be updated via a textInput.
##
## @param df data.table with arguments of highlighted element
## @param index row index of current option
##
## @return HTML for option
.create_option_textInput <- function(df, index) {
  if (is.na(df$value[index]) | is.null(df$value[index]) | df$value[index] == "'NULL'") {
    value = "''"
  } else {
    value = df$value[index]
  }
  
  ui = sprintf("textInput(inputId = '%s', label = '%s', value = %s, placeholder = 'NULL')",
               df$internal_inputId[index], df$argument[index], value)
  return(ui)
}


## Creates the HTML for an option that can be updated via a checkboxInput.
##
## @param df data.table with arguments of highlighted element
## @param index row index of current option
##
## @return HTML for option
.create_option_checkboxInput <- function(df, index) {
  ui = sprintf("checkboxInput(inputId = '%s', label = '%s', value = %s)",
               df$internal_inputId[index], df$argument[index], df$value[index])
  return(ui)
}


## Creates the HTML for an option that can be updated via a selectInput.
##
## @param df data.table with arguments of highlighted element
## @param index row index of current option
##
## @return HTML for option
.create_option_selectInput <- function(prefix, df, index) {
  if (df$default[index] != "NULL") {
    with_NULL = FALSE
  } else {
    with_NULL = TRUE
  }
  
  if (!is.na(df$choices[index])) {
    if (startsWith(df$choices[index], "sqs_option_")) {
      # TODO: get sqs_option_..._...
      all_choices = df$value[df$argument == str_replace_all(df$choices[index], prefix, "")]
      all_choices = eval(parse(text=all_choices))
    } else {
      all_choices = choices[[df$choices[index]]]
    } 
  } else {
    all_choices = c("")
  }
  
  ui = sprintf("selectInput(inputId = '%s', label = '%s', choices = %s, selected = %s)",
               df$internal_inputId[index], df$argument[index], 
               .choices_to_string(choices_list=all_choices, with_NULL=with_NULL), df$value[index])
  return(ui)
}


## Creates the HTML for an option that can be updated via a numericInput.
##
## @param df data.table with arguments of highlighted element
## @param index row index of current option
##
## @return HTML for option
.create_option_numericInput <- function(df, index) {
  range = str_split(df$range[index], ",")[[1]]
  ui = sprintf("numericInput(inputId = '%s', label = '%s', value = %s, min = %s, max = %s, step = %s)",
               df$internal_inputId[index], df$argument[index], df$value[index], 
               range[1], range[2], range[3])
  return(ui)
}


## Creates the HTML for an option that can be updated via a pickerInput.
##
## @param df data.table with arguments of highlighted element
## @param index row index of current option
##
## @return HTML for option
.create_option_pickerInput <- function(df, index) {
  if (df$default[index] != "NULL") {
    with_NULL = FALSE
  } else {
    with_NULL = TRUE
  }
  
  if (df$argument[index] %in% c("icon", "btnSearch", "btnReset", "icon_on", "icon_off")) {
    value = str_replace_all(df$value[index], "icon\\(|\\)", "")

    if (value %in% c(NULL, "'NULL'", "NULL")) {
      value = "NULL"
    } else {
      value = str_replace_all(value, "'", "")
      value = choices$icons[endsWith(choices$icons, paste0("fa-", value))]
      value = sprintf("'%s'", value)
    }

    icon_choices = choices[[df$choices[index]]]
    icon_choices = sprintf('<span class="%s"></span> %s', icon_choices,
                           str_replace_all(icon_choices, "fas fa-|fab fa-", ""))

    ui = sprintf("pickerInput(inputId = '%s', label = '%s', selected = %s, 
                 options = list('live-search' = TRUE, 'size' = 10, 'iconBase' = 'font-awesome'),
                 choices = %s, choicesOpt = list(content = %s))",
                 df$internal_inputId[index], df$argument[index], value, 
                 .choices_to_string(name=df$choices[index], with_NULL=with_NULL), 
                 .choices_to_string(choices_list=icon_choices, with_NULL=with_NULL))
    
  } else if (df$argument[index] == "language") {
    
    ui = sprintf("pickerInput(inputId = '%s', label = '%s', selected = %s, choices = %s,
                  options = list('live-search' = TRUE, 'size' = 10))",
                 df$internal_inputId[index], df$argument[index], df$value[index], 
                 .choices_to_string(df$choices[index], with_NULL=with_NULL))
    
  }
  return(ui)
}


## Creates the HTML for an option that can be updated via a selectizeInput.
##
## @param df data.table with arguments of highlighted element
## @param index row index of current option
##
## @return HTML for option
.create_option_selectizeInput <- function(df, index) {
  with_NULL = FALSE
  
  if (!is.na(df$choices[index])) {
    choices_default = choices[[df$choices[index]]]
    choices_custom = .string_to_vector(df$value[index])
    all_choices = c(choices_default, choices_custom)
    all_choices = .choices_to_string(choices_list=all_choices, with_NULL=with_NULL)
  } else {
    all_choices = df$value[index]
  }
  
  ui = sprintf("selectizeInput(inputId = '%s', label = '%s', choices = %s, selected = %s, 
               options = list(create = TRUE, placeholder = 'NULL'), multiple = TRUE)",
               df$internal_inputId[index], df$argument[index], all_choices, df$value[index])
  return(ui)
}


## Creates the HTML for an option that can be updated via a colorInput.
##
## @param df data.table with arguments of highlighted element
## @param index row index of current option
##
## @return HTML for option
.create_option_colorInput <- function(df, index) {
  ui = sprintf("colourInput(inputId = '%s', label = '%s', value = %s)",
               df$internal_inputId[index], df$argument[index], df$value[index])
  return(ui)
}


## Combines a list to a list string for usage e.g. in selectInput, pickerInput, selectizeInput.
##
## @param name if this argument is set, the column with this name in the data.table options will be used as choices_list
## @param choices_list list
## @param prefix optional prefix of the choices
## @param with_NULL if TRUE 'NULL' will be included in the choices list
##
## @return choices list as string
.choices_to_string <- function(name=NULL, choices_list=NULL, prefix=NULL, with_NULL=TRUE) {
  if (!is.null(name)) {
    choices_list = choices[[name]]
  }
  
  text = unique(choices_list)
  text = text[!is.na(text)]
  
  if (length(text) > 0) {
    if (!is.null(prefix)) {
      text = paste0("'", prefix, text, "'")
    } else {
      text = paste0("'", text, "'") 
    }
    text = paste(text, collapse=", ")
    if (with_NULL) {
      text = paste0("c('NULL', ", text, ")")
    } else {
      text = paste0("c(", text, ")")
    }
  } else {
    return('NULL')
  }
  
  return(text)
}