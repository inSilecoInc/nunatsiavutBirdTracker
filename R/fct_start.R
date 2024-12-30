#' Start function
#'
#' @export

fct_start <- function() {
    # create /docs for reports output
    dir.create(file.path(app_sys("app", "www"), "docs"))

    # create disclaimer.html
    cli::cli_alert_info("Application startup - convert md documents")
    disc_path_md <<- app_sys("app", "www", "static_docs", "disclaimer.md")
    disc_frontm <<- rmarkdown::yaml_front_matter(disc_path_md)
    disc_path_md |> 
        readLines() |> 
        markdown::mark() |>
        writeLines(disc_path_md |> fs::path_ext_set("html"))

    map_bbox <<- list(lng1 = -65.6, lat1 = 45.5, lng2 = -61.6, lat2 = 51.5)
    
    # Load birds metadata
    cli::cli_alert_info("Application startup - Set birds metadata")
    googleCloudStorageR::gcs_auth(Sys.getenv("GOOGLE_APPLICATION_CREDENTIALS"))
    birds_metadata <<- googleCloudStorageR::gcs_get_object("bird-metadata.rds",
        bucket = "bird-metadata",
        parseFunction = googleCloudStorageR::gcs_parse_rds
    )

    # Load birds locations
    bird_locations <<- arrow::gs_bucket("bird-locations") |>
        arrow::open_dataset() |>
        dplyr::collect()
    
    onStop(clean_up_app)
}

clean_up_app <- function() {
    cli::cli_alert_info("Application stopped -- cleaning up")
    unlink(file.path(app_sys("app", "www"), "docs"), recursive = TRUE)
    unlink(disc_path_md |> fs::path_ext_set("html"))
}
