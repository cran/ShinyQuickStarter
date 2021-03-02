## Creates the ui code for a specific function.
##
## @param function_name for that the ui code is generated
## @param df data.table with arguments to this function
## @param insertUI if TRUE the ui code is generated as it is needed for executing it in the addin
##                 if FALSE the ui code is generated as it is needed for the exported shiny app
## @param include_defaults if TRUE all default arguments are also included in the ui code
##
## @return generated ui code for a specific function
.df_to_ui_string <- function(function_name, df, insertUI=FALSE, include_defaults=FALSE) {
  if (!include_defaults) {
    fname = function_name
    args = arguments[arguments$function_name == fname, c("order", "required", "argument", "default")]
    
    if (nrow(args) != 0) {
      args = left_join(df, args, by="argument")
      args = args[order(args$order),]
      args$value = str_replace_all(args$value, "'NULL'", "NULL")
      args$default[is.na(args$default)] = "NA"

      df = df[
        df$argument %in% c("label", "pageLength") |
        args$required == "TRUE" | 
        str_replace_all(args$value, "'", "") != args$default,
      ]
      
      if (insertUI) {
        df$value[df$argument == "outputId"] = sprintf("'%s'", df$sqs_id[df$argument == "outputId"])
      }
    }
  }
  
  ui = sprintf("%s = %s", df$argument, df$value)
  ui = paste(ui, collapse=", ")
  ui = sprintf("%s(%s)", function_name, ui)
  ui = str_replace_all(ui, "'NULL'", "NULL")
  ui = str_replace_all(ui, "'c\\(", 'c(')
  ui = str_replace_all(ui, "\\)'", ')')
  
  return(ui)
}


## Creates the ui code.
##
## @param ui_code sprintf template for current page type
## @param uie data.table with dropped ui elements
## @param uia data.table with arguments to dropped ui elements
## @param insertUI if TRUE the server code is generated as it is needed for executing it in the addin
##                 if FALSE the server code is generated as it is needed for the exported shiny app
## @param include_defaults if TRUE all default arguments are also included in the ui code
##
## @return generated code for ui
.create_ui_code <- function(ui_code, uie, uia, insertUI=FALSE, include_defaults=TRUE) {
  
  ui_code = .recursive.ui_code(ui_code, "drop_zone", uie, uia, insertUI, include_defaults)
  ui_code = str_replace_all(ui_code, ", %s", "")
  ui_code = str_replace_all(ui_code, "\\),", "),\n")
  ui_code = str_replace_all(ui_code, ",", ",\n")
  
  ui_code = str_replace_all(ui_code, "\r", "")
  ui_code = style_text(ui_code, scope="line_breaks")
  ui_code = paste(ui_code, collapse="\n")
  
  return(ui_code)
  
}


## Creates the ui code.
##
## @param ui_code sprintf template for current page type
## @param ids sqs_ids for which the ui code is generated
## @param uie data.table with dropped ui elements
## @param uia data.table with arguments to dropped ui elements
## @param insertUI if TRUE the server code is generated as it is needed for executing it in the addin
##                 if FALSE the server code is generated as it is needed for the exported shiny app
## @param include_defaults if TRUE all default arguments are also included in the ui code
## @param index current index of nested ui elements
##
## @return generated code for ui
.recursive.ui_code <- function(ui_code, ids, uie, uia, insertUI=FALSE, include_defaults=TRUE, index=0) {
  for (i in 1:length(ids)) {
    eid = ids[i]
    if (eid == "drop_zone") {
      ui = "%s"
      type = ""
      box = "none"
    } else {
      type = uie$ui_function[uie$sqs_id == eid]
      box = elements$box[elements$function_name == type]
      arguments = uia[uia$sqs_id == eid,]
      ui = .df_to_ui_string(type, arguments, insertUI, include_defaults)

      if (insertUI) {
        if (box == "none") {
          # The sqs_ui_element can not be displayed in a box.
          
        } else if (box == "inside") {
          # The sqs_ui_element box is inside the ui element.
          ui = stri_replace_last(ui, fixed=")", ", %s)")
          temp = sprintf('div(class="sqs_ui_element", sqs_id="%s", sqs_type="%s",
                              div(class="sqs_ui_element_header sqs_%s", "%s"),
                              div(class="sqs_ui_element_body"))', eid, type, type, type)
          ui = sprintf(ui, temp)
        } else if (box == "outside") {
          # The sqs_ui_element box is around the ui element.
          ui = sprintf('div(class="sqs_ui_element", sqs_id="%s", sqs_type="%s",
                            div(class="sqs_ui_element_header sqs_%s", "%s"),
                            div(class="sqs_ui_element_body", %s))', eid, type, type, type, ui)
        }
      }
    }
    
    if (insertUI & box != "none") {
      pattern = "\\)\\)\\)$"
      replacement_1 = ", %s))), %s"
      replacement_2 = "))), %s"
    } else {
      pattern = "\\)$"
      replacement_1 = ", %s), %s"
      replacement_2 = "), %s"
    }
    
    children_ids = uie$sqs_id[uie$parent == eid]
    if (length(children_ids) > 0) {
      ui = stri_replace_last_regex(ui, pattern, replacement_1)
    } else {
      ui = stri_replace_last_regex(ui, pattern, replacement_2)
    }
    
    ui_code = stri_replace_first_regex(ui_code, "%s", ui)

    if (length(children_ids) != 0) {
      ui_code = .recursive.ui_code(ui_code, children_ids, uie, uia, insertUI, include_defaults, index+1)
      ui_code = stri_replace_first_regex(ui_code, ", %s", "")
    }
  }
  
  ui_code = str_replace_all(ui_code, "\\([ ]*,", "\\(")
  
  return(ui_code)
}


## Applies some custom changes so that the shiny app in the addin will look very similar to what it looks like when exported.
##
## @param ui current ui code
## @param uie data.table with dropped ui elements
## @param uia data.table with arguments of dropped ui elements
##
## @return HTML list with applied changes
.recursive.design_changes <- function(ui, uie, uia) {
  
  if ("attribs" %in% names(ui)) {
    if ("sqs_id" %in% names(ui$attribs)) {
      sqs_id = ui$attribs$sqs_id
      sqs_type = ui$attribs$sqs_type

      ui$attribs$class = paste(ui$attribs$class, "sqs_ui_element")
      
      # Design changes based on UI Element type.
      changes = arguments$design_changes[arguments$function_name == sqs_type]
      changes = changes[!is.na(changes)]
      changes = unlist(str_split(changes, ","))
      
      for (change in changes) {
        if (change == "width_column") {
          width = uia$value[uia$argument == "width" & uia$sqs_id == sqs_id]
          if (width == "NULL") {
            width = 12
          }
          ui$attribs$class = paste(ui$attribs$class, paste0("col-sm-", width)) 
          ui$children[[2]]$children[[1]]$attribs$class = NULL
        }
        if (change == "width_css_unit") {
          width = uia$value[uia$argument == "width" & uia$sqs_id == sqs_id]
          if (width != "NULL") {
            width = str_replace_all(width, "'", "")
            if (is.null(ui$attribs$style)) {
              style = paste0("width:", width)
            } else {
              if (nchar(ui$attribs$style) == 0) {
                style = paste0("width:", width)
              }
              style = paste(ui$attribs$style, paste0("width:", width), sep=";")
            }
            ui$attribs$style = style
            ui$children[[2]]$children[[1]]$attribs$style = "width:100%;"
          }
        }
        if (change == "offset_column") {
          offset = uia$value[uia$argument == "offset" & uia$sqs_id == sqs_id]
          offset = sprintf("offset-md-%s col-sm-offset-%s", offset, offset)
          ui$attribs$class = paste(ui$attribs$class, offset) 
        }
        if (change == "width_css_unit_top") {
          width = uia$value[uia$argument == "width" & uia$sqs_id == sqs_id]
          if (width != "NULL") {
            width = str_replace_all(width, "'", "")
            ui$attribs$style = paste(ui$attribs$style, paste0("width:", width), sep=";")
          }
        }
        if (change == "bttn_block") {
          btnn_block = uia$value[uia$argument == "block" & uia$sqs_id == sqs_id]
          if (btnn_block == TRUE) {
            ui$attribs$class = paste(ui$attribs$class, "bttn-block")
          }
        }
      }
      
      # Design Changes based on parent of UI Element.
      if (any(c("wellPanel", "inputPanel") %in% .get_parent_types(sqs_id, uie))) {
        if (any(str_detect(unlist(ui), "form-group shiny-input-container"))) {
          ui$attribs$style = paste(ui$attribs$style, "display:flex !important", sep=";")
        }
      }
      
    }
  }
  
  if ("list" %in% class(ui) | "shiny.tag" %in% class(ui)) {
    if (length(ui) > 0) {
      for (index in 1:length(ui)) {
        if ("list" %in% class(ui[[index]]) | "shiny.tag" %in% class(ui[[index]])) {
          temp = .recursive.design_changes(ui[[index]], uie, uia)
          if (!is.null(temp)) {
            ui[[index]] = temp
          }
        }
      } 
    }
  }
  
  return(ui)
  
}


## Gets all sub sqs_ids starting from a certain sqs_id.
##
## @param id start sqs_id
## @param uie data.table with dropped ui elements
## @param all_sub_ids list with all sub ids
##
## @return unique list with all sub ids
.recursive.get_sub_ids <- function(id, uie, all_sub_ids) {
  
  # Current id.
  all_sub_ids = c(all_sub_ids, id)
  
  # Children ids.
  sub_ids = uie$sqs_id[uie$parent == id]
  all_sub_ids = c(all_sub_ids, sub_ids)
  
  for (sub_id in sub_ids) {
    all_sub_ids = c(all_sub_ids, .recursive.get_sub_ids(sub_id, uie, all_sub_ids))
  }
  
  return(unique(all_sub_ids))
  
}


## Gets the function names of all parents to a certain sqs_id.
##
## @param id starting sqs_id
## @param uie data.table with dropped ui elements
##
## @return list with functions names of all parents
.get_parent_types <- function(id, uie) {
  
  parent_ids = c()
  
  while(id != "drop_zone") {
    id = uie$parent[uie$sqs_id == id]
    parent_ids = c(parent_ids, id)
  }
  
  parent_types = uie$ui_function[uie$sqs_id %in% parent_ids]

  return(parent_types)
  
}


## Gets all hrefs that are used for navigation in HTML.
##
## @param args list with items ui (ui code) and hrefs (current list of hrefs)
##
## @return list with items ui (ui code) and hrefs (current list of hrefs)
.recursive.href <- function(args) {
  
  ui = args$ui
  hrefs = args$hrefs

  if ("list" %in% class(ui) | "shiny.tag" %in% class(ui)) {
    if (length(ui) > 0) {
      if ("href" %in% names(ui)) {
        hrefs = c(hrefs, ui[["href"]])
      }
      
      for (index in 1:length(ui)) {
        if ("list" %in% class(ui[[index]]) | "shiny.tag" %in% class(ui[[index]])) {
          hrefs = .recursive.href(list(ui=ui[[index]], hrefs=hrefs))$hrefs
        }
      }
    }
  }
  
  return(list(ui=ui, hrefs=hrefs))
  
}


