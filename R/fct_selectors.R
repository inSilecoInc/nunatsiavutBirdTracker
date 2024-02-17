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
get_species_list <- function() {
    cli::cli_alert_info("Selectors - List species")
    get_s3_objects_list()$vernacular |>
        unique()
}

get_individus_list <- function(species = NULL) {
    if (!is.null(species)) {
        cli::cli_alert_info("Selectors - List tag IDs for {species}")
        get_s3_objects_list() |>
            dplyr::filter(vernacular == species) |>
            dplyr::pull(tag_id)

    } else {
        cli::cli_alert_info("Selectors - List tag IDs for all species")
        get_s3_objects_list()$tag_id
    }

}

get_s3_objects_list <- function() {
    bucket <- get_golem_config("gcs_bucket") |>
        arrow::gs_bucket()
    
    s3_objects <- bucket$ls(recursive = TRUE)

    if(length(s3_objects) == 0){
        cli::cli_alert_danger("Selectors - Bucket not found or empty")
        NULL
    } else {
        data.frame(objects = s3_objects) |>
            tidyr::separate_wider_delim(objects, delim = "/", names = c("vernacular", "tag_id", "data")) |>
            dplyr::mutate(
                vernacular = gsub("vernacular=", "", vernacular),
                tag_id = gsub("tag_id=", "", tag_id)
            ) |>
            dplyr::select(-data) |>
            dplyr::distinct()
    }
}

ind_temporal_window <- function(tag_id = NULL) {
    bucket <- get_golem_config("gcs_bucket") |>
        arrow::gs_bucket()

    arrow::open_dataset(bucket) |>
        dplyr::filter(tag_id == tag_id) |>
        dplyr::summarize(min = min(datetime), max = max(datetime)) |>
        dplyr::collect()
}