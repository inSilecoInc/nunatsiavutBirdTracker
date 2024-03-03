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

fetch_spatial_ind <- function(ds = NULL, ind = NULL) {
    data <- ds |>
        # Bug: https://issues.apache.org/jira/browse/ARROW-10305
        dplyr::collect() |>
        dplyr::filter(tag_id == ind) |>
        dplyr::select(-species, -vernacular, -band_id) 

    points <- data |>
        dplyr::arrange(desc(datetime)) |>
        sf::st_as_sf(coords = c("lon", "lat"), crs = 4326)
    
    points_to_lines <- data |>
        dplyr::arrange(desc(datetime)) |>
        dplyr::rename(lon1 = "lon", lat1 = "lat") |>
        dplyr::mutate(
            lon2 = c(NA, lon1[-length(lon1)]),
            lat2 = c(NA, lat1[-length(lat1)])
        ) |>
        dplyr::filter(!is.na(lon2), !is.na(lat2)) |>
        dplyr::mutate(
            line_id = dplyr::row_number()
        )
    
    lines <- points_to_lines |>
        dplyr::select(lon = lon1, lat = lat1, tag_id, line_id, datetime) |>
        rbind(dplyr::select(points_to_lines, lon = lon2, lat = lat2, tag_id, line_id, datetime)) |>
        sf::st_as_sf(coords = c("lon", "lat"), crs = 4326) |>
        dplyr::group_by(line_id, datetime) |>
        dplyr::summarise(do_union = FALSE) |>
        sf::st_cast("LINESTRING")


    return(list(
        points = points,
        lines = lines
    ))
}
