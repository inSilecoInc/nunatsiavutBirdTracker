#' Start function
#'
#' @export

fct_start <- function() {
    # create /docs for reports output
    dir.create(file.path(app_sys("app", "www"), "docs"))

    # create disclaimer.html
    disc_path_md <<- app_sys("app", "www", "static_docs", "disclaimer.md")
    disc_frontm <<- rmarkdown::yaml_front_matter(disc_path_md)
    markdown::mark(disc_path_md)

    map_bbox <<- list(lng1 = -65.6, lat1 = 45.5, lng2 = -61.6, lat2 = 51.5)


    onStop(clean_up_app)
}

clean_up_app <- function() {
    cli::cli_alert_info("Application stopped -- cleaning up")
    unlink(file.path(app_sys("app", "www"), "docs"), recursive = TRUE)
    unlink(disc_path_md |> fs::path_ext_set("html"))
}
