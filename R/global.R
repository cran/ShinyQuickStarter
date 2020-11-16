# Define default setting values.
code_templates = suppressWarnings(fread(.get_system_file_path("code_templates.csv"), encoding="UTF-8"))

code_templates$Code = str_replace_all(code_templates$Code, "\"\"", "'")
code_templates$Condition = str_replace_all(code_templates$Condition, "\"\"", "'")


navigation = data.table(
  Hidden_Navigation_ID = c(paste("Navigation", 1:6, sep="_")),
  Navigation_Position = c("1", "2", "2.1", "2.2", "2.3", "3"),
  Navigation_ID = c("data", "analysis", "descriptive", "visualisation", "predictive", "summary"),
  Title = c("Data", "Analysis", "Descriptive", "Visualisation", "Predictive", "Summary"),
  stringsAsFactors = FALSE
)

module = data.table(
  Hidden_Module_ID = c(paste("Module", 1:5, sep="_")),
  Module_ID = c("upload", "overview", "linear_regression", "support_vector_machine", "neural_network"),
  Return = c(FALSE, FALSE, TRUE, TRUE, TRUE),
  stringsAsFactors = FALSE
)

navigation_module = data.table(
  Hidden_Navigation_Module_ID = c("Navigation_Module_1", "Navigation_Module_2"),
  Hidden_Navigation_ID = c("Navigation_1", "Navigation_1"),
  Navigation_ID = c("data", "data"),
  Hidden_Module_ID = c("Module_1", "Module_2"),
  Module_ID = c("upload", "overview"),
  Module_Instance_ID = c("upload_1", "overview_1"),
  stringsAsFactors = FALSE
)

# Just a placeholder for maybe a future functionality.
# Needed for function_vizNetwork.R
module_io = data.table(
  Hidden_IO_ID = character(),
  Hidden_Module_ID = character(),
  Module_ID = character(),
  Position_IO = character(),
  UI_Type = character(),
  Hidden_Module_ID_2 = character(),
  UI_Element = character(),
  Server_Function = character(),
  IO_Name = character(),
  stringsAsFactors = FALSE
)
