## Create the module code.
##
## @param ui_code generated code for ui file
## @param server_code generated code for server file
## @param module_name name of module
## @param suffix suffix for module ui and server function
##
## @return generated code for module
.create_module_code <- function(ui_code, server_code, module_name, suffix) {
  
  ui_code = str_replace(ui_code, "ui <- ", "")
  server_code = gsub("server <- function(input, output, session) {", "", server_code, fixed=TRUE)
  server_code = substr(server_code, 1, nchar(server_code)-1)
  suffix = str_split(suffix, "/")[[1]]
  
  # Combine ui and server code to module format.
  module_code = "# Use the module by
  # Pasting into ui.R: %s%s(id = '%s')
  # Pasting into server.R: %s%s(id = '%s')
  
  %s%s <- function(id) {
    
    ns = NS(id)
    
    %s
  
  }
  
  %s%s <- function(id) {
    moduleServer(id, function(input, output, session) {
      
      %s

    })
  }
  "
  
  module_code = sprintf(module_code,
                        module_name, suffix[1], module_name,
                        module_name, suffix[2], module_name,
                        module_name, suffix[1], ui_code,
                        module_name, suffix[2], server_code
  )
  
  # Style again by tidyverse style guide.
  module_code = style_text(module_code, scope="line_breaks")
  module_code = paste(module_code, collapse="\n")
  module_code = str_replace_all(module_code, "\n\n\n", "\n\n")

  # Add ns() for inputId and outputsId.
  old_inputId = str_extract_all(module_code, "inputId = '.+'")[[1]]
  old_outputId = str_extract_all(module_code, "outputId = '.+'")[[1]]
  
  new_inputId = str_replace_all(old_inputId, "inputId = ", "inputId = ns(")
  new_inputId = str_replace_all(new_inputId, "'$", "')")
  
  new_outputId = str_replace_all(old_outputId, "outputId = ", "outputId = ns(")
  new_outputId = str_replace_all(new_outputId, "'$", "')")
  
  if (length(old_inputId) > 0) {
    for (i in 1:length(old_inputId)) {
      module_code = str_replace_all(module_code, old_inputId[i], new_inputId[i])
    }
  }
  
  if (length(old_outputId) > 0) {
    for (i in 1:length(old_outputId)) {
      module_code = str_replace_all(module_code, old_outputId[i], new_outputId[i])
    }
  }

  return(module_code)
  
}