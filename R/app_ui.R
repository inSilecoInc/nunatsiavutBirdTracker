#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'
#' @import shiny
#' @importFrom shinyjs useShinyjs hide show
#' @noRd

app_ui <- function(request) {
    # Leave this function for adding external resources
    golem_add_external_resources()
    bslib::page_sidebar(
        title = "Nunatsiavut bird trackers",
        theme = bslib::bs_theme(
            "bslib-dashboard-design" = "false"
        ),
        sidebar = bslib::sidebar(
            position = "right",
            width = "25%",
            varSelectInput(
                "var", "Choose your bird",
                c("Test", "Test2")
            ),
            bslib::card(
                fill = TRUE,
                bslib::card_header(
                    "Bird ID"
                ),
                bslib::card_body(
                    fill = TRUE,
                    bslib::card_title("Story"),
                    lorem::ipsum(paragraphs = 3)
                )
            )
        ),
        mapedit::editModUI("map-select")
    )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
    add_resource_path(
        "www",
        app_sys("app/www")
    )

    tags$head(
        favicon(),
        bundle_resources(
            path = app_sys("app/www"),
            app_title = "nunatsiavutBirdTracker"
        )
    )
}
