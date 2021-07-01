## Creates the server code for a specific function.
##
## @param function_name for that the server code is generated
## @param df data.table with arguments to this function
## @param include_defaults if TRUE all default arguments are also included in the server code
##
## @return generated server code for a specific function
.df_to_server_string <- function(function_name, df, include_defaults) {
  if (!include_defaults) {
    fname = function_name
    args = arguments[arguments$function_name == fname, 
                     c("order", "required", "argument", "argument_list", "default")]
    
    if (nrow(args) != 0) {
      args = as.data.table(inner_join(df, args, by=c("argument_list", "argument")))
      args = args[order(args$order),]
      args$value = str_replace_all(args$value, "'NULL'", "NULL")
      args$default[is.na(args$default)] = "NA"
      df = args[args$required == "TRUE" | args$value != args$default,]
    }
  }
  
  server = sprintf("%s = %s", df$argument, df$value)
  server = paste(server, collapse=", ")
  
  return(server)
}


## Created the server code.
##
## @param uie data.table with dropped ui elements
## @param uia data.table with arguments to dropped ui elements
## @param insertServer if TRUE the server code is generated as it is needed for executing it in the addin
##                     if FALSE the server code is generated as it is needed for the exported shiny app
##
## @return generated code for server
.create_server_code <- function(uie, uia, insertServer=FALSE, single_quotes=TRUE) {

  server_code = "%s"

  if (nrow(uie) > 0) {
    
    sqs_ids = uie$sqs_id[!is.na(uie$server_function)]

    output_functions = c()
    for (id in sqs_ids) {
      
      element = uie[uie$sqs_id == id,]
      outputId = uia$value[uia$sqs_id == id & uia$argument == "outputId"]
      
      if (!element$server_function %in% c("downloadHandler")) {
        expr_name = str_replace_all(uia$value[uia$sqs_id == id & uia$argument == "expr"], "'", "")
  
        # Expression argument in server function.
        if (is.na(expr_name)) {
          expr = ""
        } else {
          expr = server_expr$expr[server_expr$ui_function == element$ui_function &
                                    server_expr$server_function == element$server_function &
                                    server_expr$name == expr_name]
          expr = gsub('(")+', '"', expr)
        }
        
        expr = sprintf("{%s}", expr)
      } else {
        expr = server_expr$expr[server_expr$ui_function == element$ui_function &
                                  server_expr$server_function == element$server_function &
                                  server_expr$name == "example"]
        expr = gsub('(")+', '"', expr)
      }
      
      t_arguments = uia[uia$sqs_id == id & uia$function_name == element$server_function,]
      t_arguments = t_arguments[t_arguments$argument != "expr",]

      if (nrow(t_arguments) > 0) {
        t_arguments = inner_join(t_arguments, arguments[,c("function_name", "argument", "argument_list")],
                                 by=c("function_name", "argument"))
        
        # Arguments not grouped in a list.
        temp = t_arguments[is.na(t_arguments$argument_list),]
        temp = .df_to_server_string(element$server_function, temp, include_defaults=FALSE)
        
        if (nchar(temp) > 0) {
          expr = sprintf("%s, %s", expr, temp)
        }
        
        # Arguments grouped into a list.
        for (group_name in unique(t_arguments$argument_list[!is.na(t_arguments$argument_list)])) {
          temp = t_arguments[t_arguments$argument_list == group_name,]
          temp = .df_to_server_string(element$server_function, temp, include_defaults=FALSE)
          
          if (nchar(temp) > 0) {
            temp = sprintf("%s = list(%s)", group_name, temp)
            expr = sprintf("%s, %s", expr, temp)
          }
        }
      }

      if (insertServer) {
        output_function = sprintf("output[['%s']] <- %s(%s%s)", id, element$server_function, expr, "")        
      } else {
        output_function = sprintf("output$%s <- %s(%s%s)", str_replace_all(outputId, "'", ""),
                                  element$server_function, expr, "")
      }
      output_functions = c(output_functions, output_function)

    }
    
    output_functions = paste(output_functions, collapse="\n\n")
    server_code = sprintf(server_code, output_functions)
    
  } else {
    server_code = sprintf(server_code, "")
  }
  
  if (insertServer) {
    server_code = sprintf("observe({%s}, autoDestroy = TRUE)", server_code)
  } else {
    server_code = sprintf("server <- function(input, output, session) {%s}", server_code)    
  }
  server_code = str_replace_all(server_code, "\r", "")
  server_code = style_text(server_code, scope="line_breaks")
  server_code = paste(server_code, collapse="\n")
  
  # Single or double quotes.
  if (!single_quotes) {
    server_code = gsub("(?<!#)'", '"', server_code, perl=TRUE)
  }

  return(server_code)
  
}
