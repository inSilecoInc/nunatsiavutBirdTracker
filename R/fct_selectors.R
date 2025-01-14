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
    data |>
        dplyr::collect() |>
        dplyr::group_by(tag_id, vernacular, species) |>
        dplyr::mutate(year = lubridate::year(datetime)) |>
        dplyr::summarize(min = min(datetime), max = max(datetime))
}
