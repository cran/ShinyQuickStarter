.connect_tables <- function(navigation, module, navigation_module, module_io) {
  combined_tables = full_join(navigation, navigation_module, by=c("Hidden_Navigation_ID", "Navigation_ID"))
  combined_tables = full_join(combined_tables, module, by=c("Hidden_Module_ID", "Module_ID"))
  combined_tables = full_join(combined_tables, module_io, by=c("Hidden_Module_ID", "Module_ID"))


  # Combine the four tables.
  combined_tables = combined_tables[,c("Hidden_Navigation_ID", "Navigation_Position", "Navigation_ID", "Title",
                                       "Hidden_Module_ID", "Module_ID", "Return",
                                       "Hidden_IO_ID", "Position_IO", "Module_Instance_ID", "UI_Type", "UI_Element", "Server_Function", "IO_Name")]


  # Change hidden_io_id of module to hidden_module_id.
  for (index in which(combined_tables$UI_Type == "Module")) {

    module_name = combined_tables$UI_Element[index]
    module_id = module$Hidden_Module_ID[module$Module_ID == module_name]
    combined_tables$Hidden_IO_ID[index] = module_id

  }

  return(combined_tables)
}


.extract_edges <- function(combined_tables) {
  # Make edges.
  edges_1 = combined_tables[,c("Hidden_Navigation_ID", "Navigation_ID", "Hidden_Module_ID", "Module_ID")]
  edges_1$UI_Type = NA
  edges_2 = combined_tables[,c("Hidden_Module_ID", "Module_ID", "Hidden_IO_ID", "UI_Element", "UI_Type")]

  colnames(edges_1) = c("from", "from_label", "to", "to_label", "ui_type")
  colnames(edges_2) = c("from", "from_label", "to", "to_label", "ui_type")

  edges = rbindlist(list(edges_1, edges_2))
  edges = edges[!is.na(edges$from) & !is.na(edges$to),]


  # Get implicit edges between navigation items based on Position.
  nav = combined_tables[!is.na(combined_tables$Navigation_Position),
                        c("Navigation_Position", "Navigation_ID", "Hidden_Navigation_ID")]
  colnames(nav) = c("position", "to_label", "to")
  nav = unique(nav)
  setorder(nav, "position")

  nav$from = NA
  nav$from_label = NA

  for (index in 1:nrow(nav)) {

    position = str_split(nav$position[index], "\\.")[[1]]

    if (length(position) == 1) {
      nav$from[index] = "App"
      nav$from_label[index] = "app"
    } else {

      position = paste0(position[1:length(position)-1], collapse=".")
      nav$from[index] = nav$to[nav$position == position]
      nav$from_label[index] = nav$to_label[nav$position == position]
    }

  }

  nav_edges = nav[,c("from_label", "from", "to_label", "to")]
  nav_edges$ui_type = NA

  edges = rbindlist(list(nav_edges, edges), use.names=TRUE)
  edges = unique(edges)

  return(edges)
}


.extract_nodes <- function(edges) {
  # Make nodes.
  nodes = data.table(
    id = c("App", edges$from, edges$to),
    label = c("app", edges$from_label, edges$to_label),
    group = c("App", rep(NA, nrow(edges)), edges$ui_type)
  )
  nodes$group[is.na(nodes$group)] = sub("_.*", "", nodes$id[is.na(nodes$group)])
  nodes = unique(nodes)

  return(nodes)
}


.identify_node_levels <- function(nodes, edges) {
  # Extract levels.
  # Unique means every module is only once in the graph -
  # even if there are mulitple instances of it in the app.
  temp = unique(edges[,c("from", "to")])

  current_level = 0
  while(TRUE) {

    # Assign current level to all items on this level.
    only_in_from = unique(temp$from)[!(unique(temp$from) %in% unique(temp$to))]

    if (any(str_detect(only_in_from, "Navigation")) & any(str_detect(only_in_from, "Module"))) {
      only_in_from = only_in_from[str_detect(only_in_from, "Navigation")]
    }

    nodes$level[nodes$id %in% only_in_from] = current_level

    # For the case, that with removing the items on the current level, also
    # items on the next level without further subsequent levels would be removed.
    items_to_be_lost = !(unique(temp$to[temp$from %in% only_in_from]) %in%
                           unique(temp$from[!(temp$from %in% only_in_from)]))
    items_to_be_lost = unique(temp$to[temp$from %in% only_in_from])[items_to_be_lost]
    items_to_be_lost = items_to_be_lost[!str_detect(items_to_be_lost, "io_")]

    if (length(items_to_be_lost) != 0) {
      #current_level = current_level + 1

      nodes$level[nodes$id %in% items_to_be_lost &
                    !(nodes$group %in% c("Input", "Output"))] = current_level + 1
    }

    # Remove item in current levels.
    current_level = current_level + 1
    temp = temp[!(temp$from %in% only_in_from),]

    if (nrow(temp) == 0) {
      break
    }

  }
  last_layer_index = suppressWarnings(min(nodes$level[nodes$group %in% c("Input", "Output") & !is.na(nodes$level)], na.rm=TRUE))
  last_layer_index = min(last_layer_index, max(nodes$level, na.rm=TRUE)+1)
  nodes$level[nodes$group %in% c("Input", "Output")] = last_layer_index

  nodes = unique(nodes[!is.na(nodes$id)])


  # Different groups on the same level are splitted on two levels.
  nodes$new_level = nodes$level
  for (current_level in 1:max(nodes$level)) {

    groups = sort(unique(nodes$group[nodes$level == current_level]))

    if (length(groups) != 1) {
      if (!all((groups == c("Input", "Output")))) {

        if ("Navigation" %in% groups) {
          nodes$new_level[nodes$level == current_level & nodes$group != "Navigation"] =
            nodes$level[nodes$level == current_level & nodes$group != "Navigation"] + 1
          next
        }

        if ("Module" %in% groups) {
          nodes$new_level[nodes$level == current_level & nodes$group != "Module"] =
            nodes$level[nodes$level == current_level & nodes$group != "Module"] + 1
          next
        }
      }
    }
  }


  # Make sure modules are on the lowest level.
  if (nrow(nodes[nodes$group == "Module"]) != 0) {
    if (!is.infinite(min(nodes$new_level[nodes$group == "Module"]))) {
      modules_lowest_level = min(nodes$new_level[nodes$group == "Module"])
      modules_lowest_valid_level = max(nodes$new_level[nodes$group == "Navigation"]) + 1

      nodes$new_level[nodes$group == "Module" & nodes$new_level == modules_lowest_level] =
        modules_lowest_valid_level
    }
  }

  nodes$new_level[nodes$group %in% c("Input", "Output")] = max(nodes$new_level)
  nodes$level = nodes$new_level
  nodes$new_level = NULL

  return(nodes)
}


#
.app_structure <- function(navigation, module, navigation_module, module_io) {

  if (nrow(navigation) > 0) {

    tryCatch({

      combined_tables = .connect_tables(navigation, module, navigation_module, module_io)
      edges = .extract_edges(combined_tables)
      nodes = .extract_nodes(edges)
      nodes = .identify_node_levels(nodes, edges)

      visNetwork(nodes, edges)

    }, error=function(e) {
      nodes = data.table(
        id = c("App"),
        label = c("app"),
        group = c("App"),
        stringsAsFactors = FALSE
      )

      edges = data.table(
        from = character(),
        to = character(),
        stringsAsFactors = FALSE
      )
    })

  } else {

    nodes = data.table(
      id = c("App"),
      label = c("app"),
      group = c("App"),
      stringsAsFactors = FALSE
    )

    edges = data.table(
      from = character(),
      to = character(),
      stringsAsFactors = FALSE
    )

  }

  network = visNetwork(nodes, edges) %>%
    visEdges(arrows = "from") %>%
    visHierarchicalLayout() %>%
    visOptions(highlightNearest = list(enabled = T, hover = F), nodesIdSelection = F) %>%
    visGroups(groupname = "App", color = "#fffff0") %>%
    visGroups(groupname = "Navigation", color = "#4c84c3") %>%
    visGroups(groupname = "Module", color = "#a4cafd") %>%
    visGroups(groupname = "Input", color = "#ec7788") %>%
    visGroups(groupname = "Output", color = "#bada55") %>%
    visLegend()


  return(network)

}


