# Load toy data.
mpg = ggplot2::mpg
economics = ggplot2::economics
diamonds = ggplot2::diamonds


# Load addin data.
elements = fread(system.file("extdata/data/elements.csv", package="ShinyQuickStarter"),
                 na="", encoding="UTF-8")
elements = elements[elements$include %in% c("TRUE", "NAV"),]
elements = elements[order(elements$function_name),]

arguments = fread(system.file("extdata/data/arguments.csv", package="ShinyQuickStarter"), 
                  na="", encoding="UTF-8")
arguments = arguments[order(arguments$function_name, arguments$order),]
arguments$internal_inputId = paste0("sqs_option_", arguments$part, "_", arguments$argument)
arguments_excluded = arguments[is.na(arguments$include) | arguments$include == "FALSE",]
arguments_excluded = arguments_excluded[!is.na(arguments_excluded$argument),]
arguments = arguments[arguments$include %in% c("TRUE", "NAV"),]

choices = fread(system.file("extdata/data/choices.csv", package="ShinyQuickStarter"),
                na="", encoding="UTF-8")

ui_server = fread(system.file("extdata/data/ui_server.csv", package="ShinyQuickStarter"),
                  na="", encoding="UTF-8")
server_expr = fread(system.file("extdata/data/server_expr.csv", package="ShinyQuickStarter"),
                    na="", encoding="UTF-8")