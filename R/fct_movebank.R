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
fetch_movebank_study_points <- function(study_id = NULL){
    keyring::keyring_unlock(password = "Bacille78180")
    inds <- move2::movebank_retrieve("individual", study_id = study_id) |>
        janitor::remove_empty(c("rows", "cols")) |>
        dplyr::select(
            id,
            band_id = local_identifier,
            nick_name,
            species = taxon_canonical_name,
            sensor_type_ids,
            sex,
            comments
        ) |>
        dplyr::mutate(
            vernacular = dplyr::case_when(
                species == "Larus marinus" ~ "Great Black-backed Gull",
                species == "Larus hyperboreus" ~ "Glaucous Gull",
                species == "Larus argentatus" ~ "Herring Gull",
                TRUE ~ "Undefined"
            )
        ) 

    tags <- move2::movebank_retrieve("tag", study_id = study_id) |>
        janitor::remove_empty(c("rows", "cols")) |>
        dplyr::select(id, tag_id = local_identifier)

    events <- move2::movebank_retrieve("event", study_id = study_id) |>
        dplyr::rename(mb_individual_id = individual_id, mb_tag_id = tag_id) |>
        janitor::remove_empty(c("rows", "cols")) |>
        dplyr::filter(!is.na(location_lat) | !is.na(location_long)) |>
        sf::st_as_sf(coords = c("location_lat", "location_long"), crs = 4326) |>
        dplyr::filter(!is.na(mb_individual_id) & !is.na(mb_tag_id))

    inds_metadata <- events |>
        sf::st_drop_geometry() |>
        dplyr::group_by(mb_individual_id, mb_tag_id) |>
        dplyr::summarize(min = min(timestamp), max = max(timestamp)) |>
        dplyr::left_join(inds, by = c("mb_individual_id" = "id")) |>
        dplyr::left_join(tags, by = c("mb_tag_id" = "id"))

    return(list(
        metadata = inds_metadata,
        locations = events
    ))
}

fetch_movebank_study_tracks <- function(study_id = NULL) {
    keyring::keyring_unlock(password = "Bacille78180")
    move2::movebank_download_study(
            study_id, 
            sensor_type_id = "gps", 
            attributes = NULL
        ) |>
        move2::mt_track_lines() |>
        janitor::remove_empty(c("rows", "cols"))
}