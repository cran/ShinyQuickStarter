## Create the global code.
##
## @param uie
## @param uia
## @param add_documentation
## @param remove_all
## @param source_functions
## @param source_modules
##
## @return generated code for global file
.create_global_code <- function(uie, uia, add_documentation, remove_all, 
                                source_functions, source_modules, single_quotes=TRUE) {
  global_code = c()
  
  if (add_documentation) {
    global_code = c(
      global_code,
      "#' @title
      #' @author
      #' @description
      #' @details
      #' @keywords"
    )
  }

  global_code = c(global_code, .create_imports(uie, uia))
  
  if (remove_all) {
    global_code = c(
      global_code,
      "# Remove variables from environment.
      rm(list = ls())"
    )
  }
  
  if (source_functions) {
    global_code = c(
      global_code,
      "# Source functions.
      function_files = list.files(path='functions', full.names=TRUE, recursive=TRUE)
      
      for (file in function_files) {
        source(file, encoding='UTF-8')
      }"
    )
  }
  
  if (source_modules) {
    global_code = c(
      global_code,
      "# Source modules.
      module_files = list.files(path='modules', full.names=TRUE, recursive=TRUE)
      
      for (file in module_files) {
        source(file, encoding='UTF-8')
      }"
    )
  }
  
  global_code = paste(global_code, collapse="\n\n")
  global_code = style_text(global_code, scope="line_breaks")
  global_code = paste(global_code, collapse="\n")
  
  # Single or double quotes.
  if (!single_quotes) {
    global_code = gsub("(?<!#)'", '"', global_code, perl=TRUE)
  }

  return(global_code)
  
}


## Create the code for importing packages.
##
## @param uie
## @param uia
##
## @return generated code for importing packages
.create_imports <- function(uie, uia) {
  imports = .join_tables(elements, arguments, uie, uia, part="both", with_expr=TRUE)
  imports = unique(c(imports$package, imports$expr_package[imports$argument == "expr"]))
  imports = imports[!is.na(imports)]
  imports = sprintf("library(%s)", imports)
  imports = paste(imports, collapse="\n")
  
  return(imports)
}