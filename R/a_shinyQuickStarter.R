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
  # Set resource paths to static files.
  addResourcePath("images", system.file("extdata/www/jquery-easyui-1.9.10/themes/images", package="ShinyQuickStarter"))
  addResourcePath("fonts", system.file("extdata/www/fonts", package="ShinyQuickStarter"))
  
  # Define and start addin.
  app = shinyApp(
    ui = .shiny_quick_builder_ui(),
    server = .shiny_quick_builder_server()
  )
  
  runApp(app, launch.browser = TRUE)
}
