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

        labelText <- reactive({
            paste0(
                "<b>GPS deployment location</b><br/>",
                "Date: ", r$selectedBirdDescription$tag_deployment_date
            )
        })


        get_data <- reactive({
            fetch_spatial_ind(
                data = bird_locations,
                ind = r$tag_id
            )
        })

        spat_line <- reactive({
            get_data() |>
                get_track_lines(max_date = r$max_date)
        })

        observe({
            if (!is.null(r$selectedBirdDescription)) {
                stmp <- spat_line()
                if (nrow(stmp$lines)) {
                    bbox <- sf::st_bbox(stmp$lines) |>
                        as.vector()
                    color_line <- "#FFCC00"
                    leaflet::leafletProxy("map-map", session) |>
                        leaflet::clearMarkers() |>
                        leaflet::clearShapes() |>
                        leaflet::addMapPane("main", zIndex = 410) |>
                        leaflet::addMapPane("overlay", zIndex = 420) |>
                        leaflet.extras2::addArrowhead(
                            data = stmp$lines,
                            color = color_line,
                            opacity = 0.6,
                            options = c(
                                leaflet.extras2::arrowheadOptions(
                                    color = color_line,
                                    size = "10px",
                                    frequency = "300px",
                                    yawn = 60,
                                    fill = TRUE,
                                    proportionalToTotal = FALSE
                                ),
                                leaflet::pathOptions(pane = "main")
                            )
                        ) |>
                        leaflet::addCircleMarkers(
                            data = stmp$points,
                            label = ~datetime,
                            color = color_line,
                            radius = 3,
                            stroke = FALSE,
                            fillOpacity = 1,
                            options = leaflet::pathOptions(pane = "main")
                        ) |>
                        create_origin_marker(
                            isolate(r$selectedBirdDescription$longitude),
                            isolate(r$selectedBirdDescription$latitude),
                            labelText()
                        ) |>
                        leaflet::flyToBounds(
                            lng1 = bbox[1],
                            lat1 = bbox[2],
                            lng2 = bbox[3],
                            lat2 = bbox[4]
                        )
                } else {
                    cli::cli_alert_info("Map - Set bird GPS deployment")
                    leaflet::leafletProxy("map-map", session) |>
                        create_origin_marker(
                            r$selectedBirdDescription$longitude,
                            r$selectedBirdDescription$latitude,
                            labelText()
                        )
                }
            }
        })
    })
}


create_origin_marker <- function(map, lng, lat, lab, no_hide = FALSE) {
    leaflet::addCircleMarkers(
        map,
        label = htmltools::HTML(lab),
        lng = lng,
        lat = lat,
        color = "#BF2C34",
        fill = TRUE,
        radius = 10,
        stroke = FALSE,
        fillOpacity = 1,
        labelOptions = leaflet::labelOptions(noHide = no_hide),
        options = leaflet::pathOptions(pane = "overlay")
    )
}
