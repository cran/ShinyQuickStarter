#' 'RStudio' Addin for Building Shiny Apps per Drag & Drop
#'
#' This 'RStudio' addin makes the creation of 'Shiny' and 'ShinyDashboard' apps more efficient.  Besides the necessary folder structure, entire apps can be created using a drag and drop interface and customized with respect to a specific use case. The addin allows the export of the required user interface and server code at any time. By allowing the creation of modules, the addin can be used throughout the entire app development process.
#'
#' \tabular{ll}{ Package: \tab ShinyQuickStarter\cr Type: \tab Package\cr Version:
#' \tab 2.0.0\cr Date: \tab 2021-03-02\cr License: \tab GPL-3\cr Depends: \tab
#' R (>= 3.6.0)}
#'
#' @name ShinyQuickStarter-package
#' @aliases ShinyQuickStarter-package ShinyQuickStarter
#' @docType package
#' @author Leon Binder \email{leon.binder@@th-deg.de}
#' @author Bernhard Bauer \email{bernhard.bauer@@th-deg.de}
#' @author Michael Scholz \email{michael.scholz@@th-deg.de}
#' @author Bernhard Daffner \email{bernhard.daffner@@th-deg.de}
#' @author Joerg Bauer \email{joerg.bauer@@th-deg.de}
#'
#' @import shiny
#' @import shinydashboard
#' @import shinyWidgets
#' @importFrom plotly plot_ly layout add_trace plotlyOutput renderPlotly
#' @importFrom ggplot2 ggplot labs aes geom_point geom_line geom_bar coord_polar geom_text theme theme_classic geom_boxplot geom_histogram geom_tile scale_fill_gradient2 position_stack element_blank
#' @importFrom reshape2 melt
#' @importFrom fs path_home
#' @importFrom shinyFiles shinyDirButton shinyDirChoose parseDirPath getVolumes
#' @importFrom stats runif reshape
#' @importFrom shinyjs runjs useShinyjs
#' @importFrom data.table data.table as.data.table fread
#' @importFrom dplyr %>% left_join inner_join
#' @importFrom colourpicker colourInput
#' @importFrom stringr str_replace str_replace_all str_split str_sub str_detect str_extract_all
#' @importFrom stringi stri_replace_first_regex stri_replace_last stri_replace_last_regex
#' @importFrom styler style_text
#' @importFrom shinyalert shinyalert useShinyalert

NULL
