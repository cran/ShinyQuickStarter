## Joins the meta data with the dropped ui elements.
## 
## @param g_elements data.table with meta data of ui elements
## @param g_arguments data.table with meta data of arguments of ui elements
## @param elements data.table with dropped ui elements
## @param arguments data.table with arguments of dropped ui elements
## @param part if 'ui_function' only the ui_function column in elements is considered
##             if 'server_function' only the server_function column in elements is considered
##             if 'both' both columns in elements are considered
##
## @return the joined data.table
.join_tables <- function(g_elements, g_arguments, elements, arguments, part="ui_function", with_expr=FALSE) {
  
  if (part == "both") {
    parts = c("ui_function", "server_function")
  } else {
    parts = part
  }
  
  for (index in 1:length(parts)) {
    part = parts[index]
    by = eval(parse(text=sprintf("c('%s'='function_name')", part)))
    table = left_join(elements, g_elements, by=by)
    table = left_join(table, arguments, by="sqs_id")
    by = eval(parse(text=sprintf("c('%s'='function_name', 'argument'='argument')", part)))
    table = left_join(table, g_arguments, by=by)
    
    if (with_expr) {
      expr = server_expr
      expr$name = sprintf("'%s'", expr$name)
      table = left_join(table, expr, by=c("ui_function"="ui_function", 
                                          "server_function"="server_function", 
                                          "value"="name"))
    }
    
    if (index > 1) {
      result = rbind(result, table)
    } else {
      result = table
    }
  }

  result = result[!is.na(result$include.x),]
  
  return(result)
}


## Combines all reactive values to an input element into a list of values.
##
## @inputs A named list of values
##
## @return A list where connected reactive input values are combined by input
.combine_inputs <- function(inputs) {
  
  if (!is.null(inputs)) {
    names(inputs) = str_replace_all(names(inputs), "[0-9]", "")
    new_inputs = list()
    
    for (name in unique(names(inputs))) {
      values = as.vector(inputs[which(names(inputs) == name)])
      
      if (length(values) > 1) {
        values = sprintf("c(%s)", paste(values, collapse=","))
      }
      
      new_inputs[[name]] = values
    }
    
    return(new_inputs)
  } else {
    return(NULL)
  }
  
}


## Creates the data structure of a navigation tree to be used by JS.
##
## @param page_type the choosen page type of the shiny app
## @param id_index 
## @param id current sqs_id
## @param uie data.table with dropped ui elements
## @param uia data.table with arguments of dropped ui elements
## @param tree current tree structure
##
## @return tree data structure
.recursive.navigation_tree <- function(page_type, id_index, id, uie, uia, tree) {

  # Current id.
  id_index = id_index + 1
  tree$id = id_index
  tree$sqs_id = id
  tree$name = uie$ui_function[uie$sqs_id == id]
  tree$category = elements$category[elements$function_name == tree$name]
  has_href = elements$has_href[elements$function_name == tree$name]
  
  # Ids or name.
  if (is.na(elements$title_id[elements$function_name == tree$name])) {
    tree$uia_title = NULL
    tree$uia_id = NULL
  } else {
    args = str_split(elements$title_id[elements$function_name == tree$name], ",")[[1]]
    
    if (args[1] == "NULL") {
      tree$uia_title = ""
    } else {
      tree$uia_title = str_replace_all(uia$value[uia$sqs_id == id & uia$argument == args[1]], "'", "")
    }
    if (args[2] == "NULL") {
      tree$uia_id = ""
    } else {
      tree$uia_id = str_replace_all(uia$value[uia$sqs_id == id & uia$argument == args[2]], "'", "") 
    }
  }
  
  # What navigation elements - if any - can be inserted here?
  if (is.na(elements$possible_add[elements$function_name == tree$name])) {
    tree$possible_add = c()
  } else {
    tree$possible_add = elements$possible_add[elements$function_name == tree$name]
    tree$possible_add = str_split(tree$possible_add, ",")[[1]]
  }
  
  # Icons.
  if (tree$category == "UI Page") {
    tree$iconCls = "fa fa-file-code"
  } else {
    if (length(tree$possible_add)) {
      tree$iconCls = "fa fa-bars"
    } else {
      tree$iconCls = ""
    }
  }
  
  # Can this element be removed?
  if (is.na(elements$removable[elements$function_name == tree$name])) {
    tree$removable = TRUE
  } else {
    tree$removable = FALSE
  }

  # Children ids.
  sub_ids = uie$sqs_id[uie$parent == id]

  # Go through all children in the current element.
  index = 1
  children = list()
  for (sub_id in sub_ids) {
    temp = .recursive.navigation_tree(page_type, id_index, sub_id, uie, uia, tree)
    children[[index]] = temp$tree
    id_index = temp$id_index
    index = index + 1
  }
  if (length(children) > 0) {
    tree$children = children 
  }

  return(list(tree=tree, id_index=id_index))
  
}


## Creates the ui element and all necessary child ui elements.
##
## @param insert_ui list with parent, sqs_id, sqs_type
## @param new_elements data.table with new ui elements
## @param new_arguments data.table with arguments of new ui elements
## @param recursive TRUE if all necessary child ui elements will also be created
##                  FALSE if only the top ui element will be created
##
## @return list with data.table of new_elements and new_arguments
.recursive.new_elements_arguments <- function(insert_ui, new_elements, new_arguments, recursive=TRUE) {
  
  sqs_id = paste0("ui_", str_sub(as.character(insert_ui$sqs_id), 3))
  
  # Create data for the ui element.
  new_element = data.table(
    parent = as.character(insert_ui$parent),
    sqs_id = as.character(sqs_id),
    ui_function = as.character(insert_ui$sqs_type),
    server_function = NA
  )
  
  args = arguments[arguments$function_name == insert_ui$sqs_type]
  if ("inputId" %in% args$argument) {
    args$default[args$argument == "inputId"] = sqs_id        
  } else if ("outputId" %in% args$argument) {
    args$default[args$argument == "outputId"] = sqs_id
    new_element$server_function = ui_server$server_function[ui_server$ui_function == insert_ui$sqs_type]
  } else if ("tabName" %in% args$argument) {
    if (!insert_ui$sqs_type %in% c("menuItem", "menuSubItem")) {
      args$default[args$argument == "tabName"] = sqs_id
    }
  } else if ("sidebarSearchForm" %in% args$function_name) {
    args$default[args$argument == "textId"] = paste0("textId_", sqs_id)
    args$default[args$argument == "buttonId"] = paste0("buttonId_", sqs_id)
  }
  
  if (nrow(args) != 0) {
    for (index in 1:nrow(args)) {
      
      if (is.na(args$transformation[index])) {
        value = eval(parse(text=args$default[index]))
      } else {
        value = sprintf('%s("%s", %s)', args$transformation[index], args$default[index],
                        args$transformation_args[index])
        value = eval(parse(text=value))
      }
      
      new_arguments = rbind(
        new_arguments,
        data.table(
          sqs_id = as.character(sqs_id),
          function_name = insert_ui$sqs_type,
          argument = as.character(args$argument[index]),
          value = as.character(value)
        )
      )
    }       
  }
  
  # Create data for the server element.
  if (!is.na(new_element$server_function)) {
    args = arguments[arguments$function_name == new_element$server_function]
    
    if (nrow(args) != 0) {
      for (index in 1:nrow(args)) {
        
        if (is.na(args$transformation[index])) {
          value = eval(parse(text=args$default[index]))
        } else {
          value = sprintf("%s('%s', %s)", args$transformation[index], args$default[index],
                          args$transformation_args[index])
          value = eval(parse(text=value))
        }
        
        new_arguments = rbind(
          new_arguments,
          data.table(
            sqs_id = as.character(sqs_id),
            function_name = as.character(new_element$server_function),
            argument = as.character(args$argument[index]),
            value = as.character(value)
          )
        )
      }       
    }
  }
  
  new_elements = rbind(new_elements, new_element)

  if (recursive) {
    required_children = elements$required_children[elements$function_name == insert_ui$sqs_type]
    
    if (length(required_children) == 0) {
      return(list(new_elements = new_elements, new_arguments = new_arguments))      
    } else {
      if (is.na(required_children)) {
        return(list(new_elements = new_elements, new_arguments = new_arguments))
      } else {
        required_children = str_split(required_children, ",")[[1]]
        
        for (required_child in required_children) {
          temp = .recursive.new_elements_arguments(
            insert_ui = list(sqs_id=runif(1,0,1), sqs_type=required_child, parent=sqs_id),
            new_elements = new_elements,
            new_arguments = new_arguments
          )
          new_elements = temp$new_elements
          new_arguments = temp$new_arguments
        }
      }
    }
  }
  
  return(list(new_elements = new_elements, new_arguments = new_arguments))

}


## Creates a data.table for the updated arguments.
##
## @param sqs_id id of updated ui element
## @param values data.table with function_name, argument, transformation, transformation_args, new_value
##
## @return data.table with updated argument values
.arguments_update <- function(sqs_id, values, transform=TRUE) {
  
  error_list = c()
  values$new_value = as.character(values$new_value)
  
  if (transform) {
    for (index in 1:nrow(values)) {
      if (!is.na(values$transformation[index])) {
        new_value = values$new_value[index]
        new_value = gsub("\\\\|\"|\'", "", new_value)
        
        # Validation errors by \, " and '.
        if (nchar(values$new_value[index]) > nchar(new_value)) {
          error_list[[values$internal_inputId[index]]] = c("The use of backslash and quotes is here not supported.")
        }
        
        # Validation function removes \, " and '.
        values$new_value[index] = sprintf('%s("%s", %s)', values$transformation[index], new_value,
                                          values$transformation_args[index])
        values$new_value[index] = eval(parse(text=values$new_value[index]))
      }
    }    
  }
  
  update = data.table(
    sqs_id = as.character(sqs_id),
    function_name = as.character(values$function_name),
    argument = as.character(values$argument),
    value = as.character(values$new_value)
  )

  return(list(
    "updates" = update,
    "error_list" = error_list
  ))
  
}





