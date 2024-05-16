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
        class = "p-0",
        theme = bslib::bs_theme(
            base_font = bslib::font_google("Poppins"),
            "bslib-dashboard-design" = "false"
        ),
        sidebar = bslib::sidebar(
            position = "left",
            width = "25%",
            mod_selectors_ui("selectors")
        ),
        bslib::layout_column_wrap(
            bslib::card(
                bslib::card_body(
                    class = "p-0",
                    full_screen = TRUE,
                    mod_map_ui("map")
                )
            ),
            mod_bird_description_ui("bird_description"),
            width = NULL,
            style = htmltools::css(grid_template_columns = "1.25fr 0.75fr")
        )
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
