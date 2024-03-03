#' select_map UI Function
#'
#' @description A shiny Module to create spatial objects.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
mod_map_ui <- function(id) {
    ns <- NS(id)
    leaflet::leafletOutput(ns("map"))
}

#' select_map Server Functions
#'
#' @noRd
mod_map_server <- function(id, r) {
    moduleServer(id, function(input, output, session) {
        ns <- session$ns

        output$map <- leaflet::renderLeaflet(base_map())

        observeEvent(r$tag_id, {
            req(r$tag_id)
            cli::cli_alert_info("Map - Fetch spatial informations for {r$tag_id}")
            stmp <- fetch_spatial_ind(ds = r$arrow_dataset, ind = r$tag_id)
            bbox <- sf::st_bbox(stmp$lines) |> as.vector()
            color <- "#FFCC00" 
            leaflet::leafletProxy("map-map", session) |>
                leaflet::clearMarkers() |>
                leaflet::clearShapes() |>
                leaflet.extras2::addArrowhead(
                    data = stmp$lines,
                    color = color,
                    opacity = 0.8,
                    options = leaflet.extras2::arrowheadOptions(
                        color = color,
                        size = "10px",
                        frequency = "100px",
                        yawn = 60,
                        fill = TRUE,
                        proportionalToTotal = FALSE
                    )
                ) |>
                leaflet::addCircleMarkers(
                    data = stmp$points,
                    label = ~datetime,
                    color = color,
                    radius = 3,
                    stroke = FALSE,
                    fillOpacity = 1
                ) |>
                leaflet::flyToBounds(
                    lng1 = bbox[1],
                    lat1 = bbox[2],
                    lng2 = bbox[3],
                    lat2 = bbox[4]
                )
        })
    })
}
