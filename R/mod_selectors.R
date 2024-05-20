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
        fluidRow(
            column(
                12,
                h5("Select a specific bird")
            ),
            column(
                12,
                selectInput(ns("vernacular"), label = "Choose the species:", choices = NULL)
            ),
            column(
                12,
                selectInput(ns("tag_id"), label = "Choose your bird:", choices = NULL)
            ),
            column(
                12,
                selectInput(ns("year"), label = "Select the year:", choices = NULL)
            ),
            column(
                12,
                hr(),
                h5("Track his movement"),
                uiOutput(ns("slider")),
                hr()
            )
        ),
        div(class = "btn-group", role = "group",
            actionButton("previous", label = "Previous bird", class="btn btn-primary p-1 my-1 mr-1"),
            actionButton("next", label = "Next bird", class="btn btn-primary p-1 my-1 ml-1")
        )
    )
}

#' select_map Server Functions
#'
#' @noRd
mod_selectors_server <- function(id, r) {
    moduleServer(id, function(input, output, session) {
        ns <- session$ns

        output$slider <- renderUI({
            tags$div(
                class = "m-2",
                sliderInput("slider", "", min = as.Date("2023-01-01"), max = as.Date("2024-01-01"), value = as.Date("2024-01-01"), animate = TRUE, sep = ",", dragRange = FALSE, step = 10)
            )
        })

        observeEvent(r$arrow_bucket, {
            cli::cli_alert_info("Selectors - Set dataset")
            r$arrow_dataset <- arrow::open_dataset(r$arrow_bucket)
        })
        
        observeEvent(r$arrow_dataset, {
            cli::cli_alert_info("Selectors - Set choices")
            r$selectors <- r$arrow_dataset |> fetch_input_choices()
        })

        observeEvent(r$selectors, {
            req(r$selectors)
            cli::cli_alert_info("Selectors - Set vernacular choices")
            vernacular_choices <- r$selectors |>
                dplyr::pull(vernacular) |>
                unique()
            updateSelectInput(session, "vernacular", choices = vernacular_choices)
        })
    
        observeEvent(input$vernacular, {
            req(input$vernacular)
            cli::cli_alert_info("Selectors - Set tag ids based on select vernacular name")
            tag_ids <- r$selectors |>
                dplyr::filter(vernacular == input$vernacular) |>
                dplyr::pull(tag_id)
            updateSelectInput(session, "tag_id", choices = tag_ids)
        })

        observeEvent(input$tag_id, {
            req(input$tag_id)
            cli::cli_alert_info("Selectors - Set tag ids based on select vernacular name")
            r$tag_id <- input$tag_id
            selectInd <- r$selectors |>
                dplyr::filter(tag_id == input$tag_id)
            updateSliderInput(session, "slider", min = selectInd$min, max = selectInd$max, value = selectInd$min)
            updateSelectInput(session, "year", choices = unlist(selectInd$years) |> sort(decreasing = TRUE))
        })

        observeEvent(input$year, {
            cli::cli_alert_info("Selectors - Set selected year")
            req(input$year)
            r$year <- input$year
        })
    })
}
