#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'
#' @noRd
app_server <- function(input, output, session) {

    r <- reactiveValues(
        disclaimer_agreed = FALSE
    )

    # disclaimer
    mod_dialog_disclaimers_server("show_dialog", r)

    # selectors
    mod_selectors_server("selectors", r)

    # timeout
    mod_timeout_client_server("session_timeout", r)

    # initiate map
    mod_map_server("map", r)

    # initiate bird description module
    mod_bird_description_server("bird_description", r)

    onSessionEnded(function() {
        cli::cli_alert_info("Session ended - cleaning up")
        # do what needs to be done!
    })
}
