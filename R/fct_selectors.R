#' selectionMap
#'
#' @description A function to select a map.
#'
#' @param data the birds locations dataset, see details
#'
#' @details 
#'
#' @return The return value, if any, from executing the function.
#'
#' @noRd

fetch_input_choices <- function(data){

    loc_years <- data |>
        dplyr::mutate(year = lubridate::year(datetime)) |>
        dplyr::select(tag_id, year) |>
        dplyr::distinct()

    loc_summary <- data |>
        dplyr::group_by(tag_id, vernacular, species) |>
        dplyr::mutate(year = lubridate::year(datetime)) |>
        dplyr::summarize(min = min(datetime), max = max(datetime))
    
    loc_summary |>
        dplyr::mutate(years = purrr::map(tag_id, \(t) {
            loc_years |>
                dplyr::filter(tag_id == t) |>
                dplyr::pull(year) |>
                unique() 
        }))
}
