#' selectors UI Function
#'
#' @description A shiny Module to create spatial objects.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
mod_selectors_ui <- function(id) {
    ns <- NS(id)
    tagList(
        selectInput(ns("vernacular"), label = "Choose the species", choices = NULL),
        selectInput(ns("tag_id"), label = "Choose your bird", choices = NULL),
        uiOutput(ns("slider"))
    )
}

#' select_map Server Functions
#'
#' @noRd
mod_selectors_server <- function(id, r) {
    moduleServer(id, function(input, output, session) {
        ns <- session$ns

        observeEvent(r$arrow_bucket, {
            cli::cli_alert_info("Selectors - Set dataset")
            r$arrow_dataset <- arrow::open_dataset(r$arrow_bucket)
        })
        
        observeEvent(r$arrow_dataset, {
            cli::cli_alert_info("Selectors - Set choices")
            r$selectors <- r$arrow_dataset |> fetch_input_choices()
        })

        observeEvent(r$selectors, {
            cli::cli_alert_info("Selectors - Set vernacular choices")
            req(r$selectors)
            vernacular_choices <- r$selectors |>
                dplyr::pull(vernacular) |>
                unique()
            updateSelectInput(session, "vernacular", choices = vernacular_choices)
        })
    
        observeEvent(list(r$selectors, input$vernacular), {
            cli::cli_alert_info("Selectors - Set tag ids based on select vernacular name")
            req(r$selectors, input$vernacular)
            tag_ids <- r$selectors |>
                dplyr::filter(vernacular == input$vernacular) |>
                dplyr::pull(tag_id)
            updateSelectInput(session, "tag_id", choices = tag_ids)
        })

        observeEvent(input$tag_id, {
            r$tag_id <- input$tag_id 
        })
    })
}
