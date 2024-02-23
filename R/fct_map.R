#' selectionMap
#'
#' @description A function to select a map.
#'
#' @param geoms a sf object.
#' @param layer a specific layer.
#' @param set_view a logical. Should the view be (re)set.
#'
#' @return The return value, if any, from executing the function.
#'
#' @noRd

base_map <- function() {
    leaflet::leaflet(height = 2000) |>
        leaflet::addProviderTiles("Esri.WorldImagery", group = "Satellite") |>
        leaflet::addProviderTiles("CartoDB.Positron", group = "Map") |>
        leaflet::addLayersControl(
            baseGroups = c("Satellite", "Map"),
            position = "bottomleft"
        )
}

fetch_spatial_ind <- function(ds = NULL, ind = NULL) {
    data <- ds |>
        # Bug: https://issues.apache.org/jira/browse/ARROW-10305
        dplyr::collect() |>
        dplyr::filter(tag_id == ind) |>
        dplyr::select(-species, -vernacular, -band_id) 

    points <- data |>
        dplyr::arrange(desc(datetime)) |>
        sf::st_as_sf(coords = c("lon", "lat"), crs = 4326)
    
    lines <- points |> sf::st_union() |> sf::st_cast("LINESTRING")

    return(list(
        points = points,
        lines = lines
    ))
}
