## Converts an argument value into a valid string that can be used for generated ui code.
##
## @param x argument value
## @param args_list list with additional options
##
## @return converted argument value
.to_string <- function(x, args_list=NA) {
  if (is.na(x) | is.null(x)) {
    return("NULL")
  } else {
    if (x == "'NULL'") {
      return(x)
    } else {
      if (!is.list(args_list)) {
        if ("regex" %in% names(args_list)) {
          if (args_list$regex == "id") {
            x = gsub("[^A-Za-z0-9 _-]", "", x)
          }
        } else {
          x = gsub("'", "", x)
        }
      } else {
        x = gsub("'", "", x)
      }
      return(sprintf("'%s'", x)) 
    }
  }
}


## Converts an argument value vector into a valid vector string that can be used for generated ui code.
##
## @param x argument value
## @param args_list list with additional options
##
## @return converted argument value
.to_string_vector <- function(text, args_list=NA) {
  if (length(text) == 0 | text %in% c("'NULL'", "NULL")) {
    text = "c('example')"
    
    if (is.list(args_list)) {
      if ("with_NULL" %in% names(args_list)) {
        if (args_list$with_NULL == "TRUE") {
          text = "c()"
        }
      }
    }
  } else {
    text = str_replace_all(text, "c\\(|\\)|'", "")
    text = str_split(text, ",")[[1]]
    text = trimws(text)

    for (i in 1:length(text)) {
      text[i] = .to_string(text[i], args_list)
    }

    text = paste(text, collapse=", ")
    text = sprintf("c(%s)", text)
  }
  
  return(text)
}


## Converts an argument value into a valid color string that can be used for generated ui code.
##
## @param x argument value
## @param args_list list with additional options
##
## @return converted argument value
.to_color_string <- function(x, args_list=NA) {
  if (is.na(x) | is.null(x)) {
    return("NULL")
  } else {
    if (x == "'NULL'") {
      return(x)
    } else {
      return(sprintf("'%s'", x)) 
    }
  }
}


## Converts an argument value into a valid css string that can be used for generated ui code.
##
## @param x argument value
## @param args_list list with additional options
##
## @return converted argument value
.to_css_unit <- function(x, args_list=NA) {
  if (is.na(x) | is.null(x)) {
    return("NULL")
  } else {
    if (x == "'NULL'") {
      return(x)
    } else {
      return(sprintf("'%s'", x)) 
    }
  }
}


## Converts an argument value into a valid icon function that can be used for generated ui code.
##
## @param x argument value
## @param args_list list with additional options
##
## @return converted argument value
.to_icon <- function(x, args_list=NA) {
  if (x == "NULL") {
    return(x)
  } else {
    x = paste0("icon('", str_replace_all(x, "fas fa-|fab fa-", ""), "')")
    return(x)
  }
}


## Converts an argument value into a valid numeric that can be used for generated ui code.
##
## @param x argument value
## @param args_list list with additional options
##
## @return converted argument value
.to_numeric <- function(x, args_list=NA) {
  if (x == "") {
    return("'NULL'")
  } else {
    return(x)
  }
}


## Converts an argument value into a valid date string that can be used for generated ui code.
##
## @param x argument value
## @param args_list list with additional options
##
## @return converted argument value
.to_date_string <- function(x, args_list=NA) {
  if (is.na(x) | is.null(x) | x == "NULL" | x == "'NULL'") {
    return("NULL")
  } else {
    date = as.character(as.Date(as.numeric(x), origin="1970-01-01"))
    date = sprintf('%s', date)
    return(date)  
  }
}


## Converts an argument value into a valid timezone string that can be used for generated ui code.
##
## @param x argument value
## @param args_list list with additional options
##
## @return converted argument value
.to_timezone <- function(text, args_list=NA) {
  text = str_replace_all(text, "UTC|:", "")
  text = paste0("'", text, "'")
  return(text)
}


## Converts an argument value vector into a valid numeric vector string that can be used for generated ui code.
##
## @param x argument value
## @param args_list list with additional options
##
## @return converted argument value
.to_numeric_vector <- function(text, args_list=NA) {
  if (length(text) == 0 | text %in% c("'NULL'", "NULL")) {
    return("c()")
  } else {
    text = str_replace_all(text, "c\\(|\\)|'", "")
    text = str_split(text, ",")[[1]]
    text = as.numeric(text)
    text = paste(text, collapse=",")
    text = sprintf("c(%s)", text)
    return(text)
  }
}


## Converts a vector string to a string vector.
##
## @param text a vector string
##
## @return a string vector
.string_to_vector <- function(text) {
  vector = str_replace_all(text, "c\\(|\\)|'", "")
  vector = str_split(vector, ", ")[[1]]
  vector = as.character(vector)
  
  return(vector)
}
