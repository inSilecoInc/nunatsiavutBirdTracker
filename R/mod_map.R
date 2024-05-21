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

        observeEvent(r$selectedBirdDescription, {
            req(r$selectedBirdDescription)
            cli::cli_alert_info("Map - Set bird GPS deployment")

            labelText <- paste0("<b>GPS deployment location</b><br/>",
                                "Date: ", r$selectedBirdDescription$tag_deployment_date)

            leaflet::leafletProxy("map-map", session) |>
                leaflet::addCircleMarkers(
                    label = htmltools::HTML(labelText),
                    lng = r$selectedBirdDescription$longitude,
                    lat = r$selectedBirdDescription$latitude,
                    color = "#BF2C34",
                    fill = TRUE,
                    radius = 10,
                    stroke = FALSE,
                    fillOpacity = 1,
                    labelOptions = leaflet::labelOptions(noHide = TRUE)
                )

        })

        observeEvent(r$tag_id, {
            req(r$tag_id)
            cli::cli_alert_info("Map - Fetch spatial informations for {r$tag_id}")
            
            stmp <- fetch_spatial_ind(ds = r$arrow_dataset, ind = r$tag_id)
            bbox <- sf::st_bbox(stmp$lines) |> as.vector()
            color_line <- "#FFCC00"
            
            leaflet::leafletProxy("map-map", session) |>
                leaflet::clearMarkers() |>
                leaflet::clearShapes() |>
                leaflet.extras2::addArrowhead(
                    data = stmp$lines,
                    color = color_line,
                    opacity = 0.6,
                    options = leaflet.extras2::arrowheadOptions(
                        color = color_line,
                        size = "10px",
                        frequency = "300px",
                        yawn = 60,
                        fill = TRUE,
                        proportionalToTotal = FALSE
                    )
                ) |>
                leaflet::addCircleMarkers(
                    data = stmp$points,
                    label = ~datetime,
                    color = color_line,
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
