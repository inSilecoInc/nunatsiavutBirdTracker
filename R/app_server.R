#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'
#' @noRd
app_server <- function(input, output, session) {
    #
    observe({
        updateTabsetPanel(
            session,
            "tabset_main_right",
            selected = input$tabset_main_left
        )
    })
    #
    r <- reactiveValues(
        map = base_map(),
        geom_slc = NULL,
        disclaimer_agreed = FALSE
    )

    # disclaimer
    mod_dialog_disclaimers_server("show_dialog", r)

    # timeout
    mod_timeout_client_server("session_timeout", r)

    # initiate map
    mod_select_map_server("map-setting", r)

    # generate map
    observeEvent(r$map, {
        r$geom_slc <- callModule(
            mapedit::editMod,
            leafmap = r$map,
            id = "map-select"
        )
    })

    # reporting
    mod_render_doc_server("report", r)
    observeEvent(r$report_html, {
        output$preview_report <- renderUI({
            # looks like it has to be a relative path starting with www/
            pth <- fs::path_rel(r$report_html, app_sys("app"))
            tags$iframe(
                # looks like path must be relative
                id = "iframe_report", src = pth, width = "100%"
            )
        })
    })

    onSessionEnded(function() {
        cli::cli_alert_info("Session ended -- cleaning up")
        # do what needs to be done!
    })
}
