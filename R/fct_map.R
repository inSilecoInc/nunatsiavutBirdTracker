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

fetch_spatial_ind <- function(ds = NULL, ind = NULL, year = NULL, 
    max_date = NULL) {
    data <- ds |>
        dplyr::collect() |>
        dplyr::filter(tag_id == ind) |>
        dplyr::select(-species, -vernacular, -band_id)

    if (!is.null(year)) {
        data <- dplyr::filter(data, format(datetime, format = "%Y") == year)
    }
    if (!is.null(max_date)) {
        data <- data |> 
            dplyr::filter(datetime <= max_date)
    }

    traj_points <- data |>
        dplyr::arrange(datetime) |>
        sf::st_as_sf(coords = c("lon", "lat"), crs = 4326)

    # see https://github.com/r-spatial/sf/issues/692
    traj_line <- traj_points |>
        dplyr::group_by(tag_id) |>
        dplyr::summarize(do_union = FALSE) |>
        sf::st_cast("LINESTRING")

    return(list(
        points = traj_points,
        lines = traj_line
    ))
}
