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
        leaflet::addProviderTiles("CartoDB.DarkMatter", group = "Map") |>
        leaflet::addLayersControl(
            baseGroups = c("Satellite", "Map"),
            position = "bottomleft"
        )
}

fetch_spatial_ind <- function(ds = NULL, ind = NULL, year = NULL) {
    data <- ds |>
        dplyr::collect() |>
        dplyr::filter(tag_id == ind) |>
        dplyr::select(-species, -vernacular, -band_id)
    
    if (!is.null(year)) {
        data <- dplyr::filter(data, format(datetime, format = "%Y") == year) 
    }

    points <- data |>
        dplyr::arrange(datetime) |>
        sf::st_as_sf(coords = c("lon", "lat"), crs = 4326)

    lines <- points |> sf::st_union() |> sf::st_cast("LINESTRING")

    return(list(
        points = points,
        lines = lines
    ))
}
