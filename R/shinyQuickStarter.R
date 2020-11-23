#' Starts the ShinyQuickStarter Addin in RStudio.
#'
#' @author Leon Binder \email{leon.binder@@th-deg.de}
#' @author Bernhard Bauer \email{bernhard.bauer@@th-deg.de}
#' @author Michael Scholz \email{michael.scholz@@th-deg.de}
#' @author Bernhard Daffner \email{bernhard.daffner@@th-deg.de}
#' @author Joerg Bauer \email{joerg.bauer@@th-deg.de}
#' @examples 
#' \dontrun{shinyQuickStarter()}
#' @export
shinyQuickStarter <- function() {
  
  warning("ShinyQuickStarter currently only works if you install it by source - 
  otherwise there will be the error 'Couldn't normalize path in `addResourcePath`': \n
  use:  install.packages('ShinyQuickStarter', type='source') \n
  Do you want to proceed? [y]/n", immediate.=TRUE)
  
  user_input = readline()
  
  cat(user_input)
  
  if (user_input == "y" | user_input == "") {
    shiny::addResourcePath("colourpicker-binding", 
                           system.file("srcjs", package = "colourpicker"))
    shiny::addResourcePath("colourpicker-lib", 
                           system.file("www", "shared", "colourpicker", package = "colourpicker"))

    runApp(list(ui = .shiny_quick_starter_ui, server = .shiny_quick_starter_server),
           launch.browser = TRUE)
  }
}
