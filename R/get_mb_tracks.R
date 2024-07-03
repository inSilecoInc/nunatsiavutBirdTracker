#' Retrieve movebank tracks
#'
#' @description Retrieve tracks from movebank project Id. 
#'
#' @param mb_user movebank username.
#' @param mb_password movebank password.
#' @param study_id movebank studyId.
#'
#' @return Return a data.frame of 7 columns:
#' - tag_id: Individual tag id
#' - band_id: Individual band id
#' - lon: Longitude of the location
#' - lat: Latitude of the location
#' - datetime: Datetime of the location
#' - species: Species latin name
#' - vernacular: Species english name
#'
#' @export 

get_mb_tracks <- function(mb_user=NULL, mb_password=NULL, study_id=2854587542){

    suppressWarnings({
        suppressMessages({
            loginStored <- move::movebankLogin(username = mb_user, password = mb_password)

            tracks <- move::getMovebankData(study = study_id, login = loginStored, removeDuplicatedTimestamps = TRUE, deploymentAsIndividuals = TRUE)@data

            animals <- move::getMovebankAnimals(study = study_id, login = loginStored) |>
                dplyr::select(tag_id, local_identifier, tag_local_identifier, sensor_type_id, taxon_canonical_name)

            tracks_df <- tracks |>
                dplyr::left_join(animals)
        })
    })

    tracks_df <- tracks_df |>
        janitor::remove_empty(c("rows", "cols")) |>
        janitor::remove_constant() |>
        dplyr::filter(sensor_type == "GPS") |>
        dplyr::select(
            tag_id = tag_local_identifier,
            band_id = local_identifier,
            lon = location_long,
            lat = location_lat,
            datetime = timestamp,
            species = taxon_canonical_name
        ) |>
        dplyr::mutate(
            vernacular = dplyr::case_when(
                species == "Larus marinus" ~ "Great Black-backed Gull",
                species == "Larus hyperboreus" ~ "Glaucous Gull",
                species == "Larus argentatus" ~ "Herring Gull",
                TRUE ~ "Undefined"
            ),
            tag_id = as.factor(tag_id),
            datetime = as.POSIXct(datetime)
        )
    
    return(tracks_df)
}
