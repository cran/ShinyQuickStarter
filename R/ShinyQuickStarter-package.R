#' Quick Setup for ShinyDashboard Apps
#'
#' This RStudio addin enables faster creation of the project structure and design of ShinyDashboard apps. 
#' The graphical interface allows you to add certain code templates interactively. In addition to generating 
#' the basic project structure, the navigation in the app itself can also be defined or the app can be structured with modules.
#'
#' \tabular{ll}{ Package: \tab ShinyQuickStarter\cr Type: \tab Package\cr Version:
#' \tab 1.0.1\cr Date: \tab 2020-11-23\cr License: \tab GPL-3\cr Depends: \tab
#' R (>= 3.2.0)}
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
#' @import miniUI
#' @import data.table
#' @import readr
#' @import rlist
#' @import stringi
#' @import styler
#' @import visNetwork
#' @importFrom shinyalert shinyalert useShinyalert
#' @importFrom DT renderDT formatStyle styleEqual DTOutput
#' @importFrom shinycssloaders withSpinner
#' @importFrom shinyjs click useShinyjs hidden
#' @importFrom colourpicker colourInput updateColourInput
#' @importFrom shinyFiles parseDirPath shinyDirButton getVolumes shinyDirChoose
#' @importFrom shinyWidgets radioGroupButtons updateRadioGroupButtons
#' @importFrom dplyr inner_join full_join
#' @importFrom fs path_home
#' @importFrom grDevices colorRampPalette
#' @importFrom stringr str_detect str_replace_all str_split str_replace str_split_fixed str_extract_all
#' @importFrom magrittr %>%
#' @importFrom utils tail stack
#' @importFrom stats setNames

NULL
