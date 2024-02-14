#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'
#' @import shiny
#' @importFrom shinyjs useShinyjs hide show
#' @noRd

app_ui <- function(request) {
    tagList(
        # Leave this function for adding external resources
        golem_add_external_resources(),
        # Your application UI logic
        fluidPage(
            theme = bslib::bs_theme(version = 5),
            useShinyjs(),
            mod_timeout_client_ui("session_timeout"),
            sidebarLayout(
                sidebarPanel(
                    fluidRow(
                        h2("inSileco Shiny Template"),
                        tabsetPanel(
                            id = "tabset_main_left",
                            tabPanel(
                                title = "Map",
                                icon = icon("map"),
                                mod_select_map_ui("map-setting")
                            ),
                            tabPanel(
                                title = "Report",
                                icon = icon("file"),
                                mod_render_doc_ui("report")
                            )
                        )
                    ),
                    fluidRow(
                        column(
                            6,
                            bookmarkButton(label = "Share this application view")
                        )
                    )
                ),
                mainPanel(
                    tabsetPanel(
                        id = "tabset_main_right",
                        tabPanel(
                            title = "Map",
                            icon = icon("map"),
                            mapedit::editModUI("map-select")
                        ),
                        tabPanel(
                            title = "Report",
                            icon = icon("file"),
                            htmlOutput("preview_report")
                        )
                    )
                )
            )
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
            app_title = "iseShinyTemplate"
        )
    )
}
