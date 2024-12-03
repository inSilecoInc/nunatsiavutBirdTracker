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

get_mb_tracks <- function(mb_user = Sys.getenv("MB_USER"), mb_password = Sys.getenv("MB_PASSWORD"), study_id = NULL){

    suppressWarnings({
        suppressMessages({
            loginStored <- move::movebankLogin(username = mb_user, password = mb_password)

            tracks <- move::getMovebankData(study = study_id, login = loginStored, removeDuplicatedTimestamps = TRUE, deploymentAsIndividuals = TRUE)@data

            animals <- move::getMovebankAnimals(study = study_id, login = loginStored) 
        })
    })

    tracks_df <- tracks |>
        dplyr::left_join(animals) |>
        dplyr::select(
            tag_id = tag_local_identifier,
            band_id = local_identifier,
            lon = location_long,
            lat = location_lat,
            datetime = timestamp,
            species = taxon_canonical_name,
            sensor_type,
            argos_lc
        ) |>
        janitor::remove_empty(c("rows", "cols")) |>
        dplyr::mutate(
            vernacular = dplyr::case_when(
                species == "Larus marinus" ~ "Great Black-backed Gull",
                species == "Larus hyperboreus" ~ "Glaucous Gull",
                species == "Larus argentatus" ~ "Herring Gull",
                species == "Somateria mollissima" ~ "Common eider",
                TRUE ~ "Undefined"
            ),
            tag_id = as.factor(tag_id),
            datetime = as.POSIXct(datetime)
        )


    # Studies cleanup
    if(study_id == 2854587542) {
        tracks_df <- dplyr::filter(tracks_df, sensor_type == "GPS")
    } else if(study_id == 4036904918) {
        tracks_df <- dplyr::filter(tracks_df, sensor_type == "Argos Doppler Shift")
    }
    
    return(tracks_df)
}
