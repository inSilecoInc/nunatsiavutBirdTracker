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

fetch_spatial_ind <- function(data = NULL, ind = NULL) {
    cli::cli_alert_info("Map - Fetching spatial informations for {ind}.")
        data |>
            dplyr::filter(tag_id == as.numeric(ind)) |>
            dplyr::collect() |>
            dplyr::select(-species, -vernacular, -band_id)
}


# use data frame from fetch spatial then fileter
get_track_lines <- function(.df, max_date = NULL, year = NULL) {
    cli::cli_alert_info("Map - Creating track lines.")
    if (!is.null(year)) {
        data <- dplyr::filter(.df, format(datetime, format = "%Y") == year)
    } else if (!is.null(max_date)) {
        data <- .df |>
            dplyr::filter(datetime <= max_date)
    } else {
        stop("either `max_date` or `year` must be non-NULL")
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
