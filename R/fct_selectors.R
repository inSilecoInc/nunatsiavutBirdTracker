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

fetch_input_choices <- function(ds = NULL){
    ds |> dplyr::group_by(tag_id, vernacular, species) |>
        dplyr::summarize(min = min(datetime), max = max(datetime)) |>
        dplyr::collect()
}
