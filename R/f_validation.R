## Validates the inputs/arguments of the updated element and gives back errors if the inputs are not valid.
##
## @param highlighted sqs_id of highlighted ui element
## @param uie data.table with dropped ui elements
## @param uia data.table with arguments of dropped ui elements
## @param updates data.table with updated arguments to highlighted ui element
##
## @return NULL if all inputs are valid, or a list of validation errors
.validate_inputs <- function(highlighted, uie, uia, updates, transformation_errors) {
  
  uia = uia[uia$sqs_id != highlighted,]
  uia = rbind(uia, updates)

  full_table = .join_tables(elements, arguments, uie, uia, part="both")
  table = full_table[full_table$sqs_id == highlighted,]
  table$value = str_replace_all(table$value, "'", "")

  errors = list()
  if (nrow(table) > 0) {
    for (x in 1:nrow(table)) {
      error_list = transformation_errors[[table$internal_inputId[x]]]

      if (!is.na(table$validation[x])) {
        validations = str_split(table$validation[x], ";")[[1]]
        validations = str_replace_all(validations, "\n", "")
        args_lists = str_split(table$validation_args[x], ";")[[1]]
        args_lists = str_replace_all(args_lists, "\n", "")
        
        for (index in 1:length(validations)) {
          validation = sprintf("%s('%s', '%s', %s, %s)", validations[index], table$argument[x], table$value[x],
                               "full_table, highlighted", args_lists[index])
          error = eval(parse(text=validation))
          error_list = c(error_list, error)
        }
      }
      
      if (length(error_list) > 0) {
        error_list = paste(error_list, collapse="\n")
      } else {
        error_list = NULL
      }
      
      if (!is.null(error_list)) {
        errors[[table$internal_inputId[x]]] = error_list
      }
    }
  }

  if (length(errors) == 0) {
    return(NULL)
  } else {
    return(errors)
  }
  
}


## Validates an inputId.
##
## @param name argument name
## @param x updated argument value
## @param highlighted sqs_id of highlighted ui element
## @param additional list of options
##
## @return NULL if the input is valid, or a list of validation errors
.validate_inputId <- function(name, x, table, highlighted, args_list=NA) {
  
  errors = c()

  # Empty string.
  if (x %in% c(NULL, "", "NULL", "'NULL'")) {
    if (!args_list$allow_NULL) {
      errors = c(errors, "The id cannot be empty.")
    }
  } else {
    # String with invalid characters.
    if (nchar(gsub("^[A-Za-z][A-Za-z0-9_:\\.-]*", "", x)) != 0) {
      errors = c(errors, "The id is not valid. It needs to match the regex ^[A-Za-z][A-Za-z0-9_:\\.-]*")
    } 
  }

  # Duplicates.
  inputIds = table$value[table$argument %in% c("inputIds", "inputId", "textId", "buttonId")]
  inputIds = unlist(lapply(inputIds, .string_to_vector))

  if (sum(x == inputIds) > 1) {
    errors = c(errors, "The id has to be unique.")
  }
  
  if (length(errors) == 0) {
    return(NULL)
  } else {
    return(errors)
  }
  
}


## Validates an inputId vector.
##
## @param name argument name
## @param x updated argument value
## @param highlighted sqs_id of highlighted ui element
## @param additional list of options
##
## @return NULL if the input is valid, or a list of validation errors
.validate_inputId_vector <- function(name, x, table, highlighted, args_list=NA) {
  
  errors = c()
  
  x = .to_string_vector(x)
  x = .string_to_vector(x)

  for (item in x) {
    errors = c(errors, .validate_inputId(name, item, table, highlighted, args_list=NA))
  }
  
  if (length(errors) == 0) {
    return(NULL)
  } else {
    return(unique(errors))
  }
  
}


## Validates an outputId.
##
## @param name argument name
## @param x updated argument value
## @param highlighted sqs_id of highlighted ui element
## @param additional list of options
##
## @return NULL if the input is valid, or a list of validation errors
.validate_outputId <- function(name, x, table, highlighted, args_list=NA) {

  errors = c()
  
  # Empty string.
  if (x %in% c(NULL, "", "NULL", "'NULL'")) {
    errors = c(errors, "The outputId cannot be empty.")
  } else {
    # String with invalid characters.
    if (nchar(gsub("^[A-Za-z][A-Za-z0-9_:\\.-]*", "", x)) != 0) {
      errors = c(errors, "The outputId is not valid. It needs to match the regex ^[A-Za-z][A-Za-z0-9_:\\.-]*")
    } 
  }
  
  # Duplicate.
  if (nrow(table[table$argument == "outputId" & table$value == .to_string(x),]) != 1) {
    errors = c(errors, "The outputId has to be unique.")
  }
  
  if (length(errors) == 0) {
    return(NULL)
  } else {
    return(errors)
  }
  
}


## Validates a css unit string.
##
## @param name argument name
## @param x updated argument value
## @param highlighted sqs_id of highlighted ui element
## @param additional list of options
##
## @return NULL if the input is valid, or a list of validation errors
.validate_css_unit <- function(name, x, table, highlighted, args_list=NA) {
  m = tryCatch({
    if (!x %in% c(NULL, "", "NULL", "'NULL'")) {
      validateCssUnit(x)      
    }
    m = NULL
  }, error = function(e) {
    m = as.character(e)
  })
  
  return(m)
}


## Validates if a numeric is the valid range.
##
## @param name argument name
## @param x updated argument value
## @param highlighted sqs_id of highlighted ui element
## @param additional list of options
##
## @return NULL if the input is valid, or a list of validation errors
.validate_numeric_range <- function(name, x, table, highlighted, args_list=NA) {
  table = table[table$sqs_id == highlighted,]
  range = as.numeric(str_split(table$range[table$argument == name], ",")[[1]])
  range = sprintf("seq(%s, %s, %s)", range[1], range[2], range[3])
  range = eval(parse(text=range))

  if (length(x) == 0) {
    return(NULL)
  } else {
    if (x %in% range) {
      return(NULL)
    } else {
      return("Value is out of range.")
    }
  }
}


## Validates a numeric.
##
## @param name argument name
## @param x updated argument value
## @param highlighted sqs_id of highlighted ui element
## @param additional list of options
##
## @return NULL if the input is valid, or a list of validation errors
.validate_numeric <- function(name, x, table, highlighted, args_list=NA) {
  if (x %in% c(NULL, "", "NULL", "'NULL'")) {
    return(NULL)
  } else {
    if (is.na(suppressWarnings(as.numeric(x)))) {
      return("Value is not numeric.")
    } else {
      return(NULL)
    }
  }
}


## Validates a date.
##
## @param name argument name
## @param x updated argument value
## @param highlighted sqs_id of highlighted ui element
## @param additional list of options
##
## @return NULL if the input is valid, or a list of validation errors
.validate_date <- function(name, x, table, highlighted, args_list=NA) {
  
  x = str_replace_all(x, "'", "")

  if (x %in% c(NULL, "", "NULL", "'NULL'")) {
    return(NULL)
  } else {
    callback = try(as.Date(x, format="%Y-%m-%d"))
    if("try-error" %in% class(callback) || is.na(callback)) {
      return("Invalid date. Date needs to be in the format: yyy-mm-dd")
    } else {
      return(NULL)
    }
  }
    
}


## Validates if the input has the same length as some other input.
##
## @param name argument name
## @param x updated argument value
## @param highlighted sqs_id of highlighted ui element
## @param additional list of options
##
## @return NULL if the input is valid, or a list of validation errors
.validate_same_length <- function(name, x, table, highlighted, args_list=NA) {
  
  a = table$value[table$argument == name]
  b = table$value[table$argument == args_list$compare_to]
  
  a = eval(parse(text=a))
  b = eval(parse(text=b))

  if (length(a) != length(b)) {
    return(sprintf("The vectors for the arguments %s and %s do not have the same length.",
                   name, args_list$compare_to))
  } else {
    return(NULL)
  }
  
}


## Validates a badgeLabel.
##
## @param name argument name
## @param x updated argument value
## @param highlighted sqs_id of highlighted ui element
## @param additional list of options
##
## @return NULL if the input is valid, or a list of validation errors
.validate_badgeLabel <- function(name, x, table, highlighted, args_list=NA) {
  
  errors = c()
  if (!x %in% c(NULL, "", "NULL", "'NULL'")) {
    if (any(c("menuItem", "menuSubItem") %in% table$function_name[table$parent == highlighted])) {
      errors = c(errors, "Can't have both badge and subItems.")
    }
  }
  
  return(errors)
  
}

