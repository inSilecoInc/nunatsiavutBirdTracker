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
                hr(),
                h5("Track their movement"),
                div(
                    class = "m-2",
                    sliderInput(
                        ns("slider_date"),
                        "",
                        min = as.Date("2023-01-01"),
                        max = as.Date("2024-01-01"),
                        value = as.Date("2024-01-01"),
                        animate = animationOptions(interval = 2000),
                        sep = ",",
                        dragRange = FALSE,
                        step = 1,
                        timeFormat = "%F" 
                    )
                ),
                hr()
            )
        ),
        div(
            class = "btn-group", role = "group",
            actionButton(ns("prev_bird"), label = "Previous bird", class = "btn btn-primary p-1 my-1 mr-1"),
            actionButton(ns("next_bird"), label = "Next bird", class = "btn btn-primary p-1 my-1 ml-1")
        )
    )
}

#' select_map Server Functions
#'
#' @noRd
mod_selectors_server <- function(id, r) {
    moduleServer(id, function(input, output, session) {
        ns <- session$ns

        observe({
            cli::cli_alert_info("Selectors - Set choices")
        
            r$selectors <- fetch_input_choices(data = bird_locations)
            
            cli::cli_alert_info("Selectors - Set vernacular choices")

            r$vernacular_choices <- r$selectors |>
                dplyr::pull(vernacular) |>
                unique()
            
            updateSelectInput(
                session,
                "vernacular",
                choices = r$vernacular_choices
            )
            cli::cli_alert_info("Selectors - Initial setup done")
        })

        observe({
            cli::cli_alert_info("Selectors - Set vernacular name")

            ids_name <- r$selectors |>
                dplyr::filter(vernacular == input$vernacular) |>
                dplyr::left_join(dplyr::select(birds_metadata, tag_id, name)) |>
                dplyr::mutate(name = ifelse(is.na(name), glue::glue("Unnamed ({tag_id})"),  glue::glue("{name} ({tag_id})"))) |> dplyr::select(name, tag_id)

            r$tag_ids <- ids_name$tag_id
            choices <- as.list(ids_name$tag_id) |>
                setNames(ids_name$name)

            updateSelectInput(
                session,
                "tag_id",
                choices = choices
            )
        })

        observeEvent(input$next_bird, {
            cli::cli_alert_info("Selectors - Get next bird")
            id <- which(input$tag_id == r$tag_ids)
            next_id <- ifelse(id < length(r$tag_ids), id + 1, 1)
            slc_indiv <- r$tag_ids[next_id]
            updateSelectInput(
                session,
                "tag_id",
                selected = slc_indiv
            )
        })

        observeEvent(input$prev_bird, {
            cli::cli_alert_info("Selectors - Get previous bird")
            id <- which(input$tag_id == r$tag_ids)
            prev_id <- ifelse(id > 1, id - 1, length(r$tag_ids))
            slc_indiv <- r$tag_ids[prev_id]
            updateSelectInput(
                session,
                "tag_id",
                selected = slc_indiv
            )
        })

        observe({
            cli::cli_alert_info("Selectors - Set slider")
            r$tag_id <- input$tag_id
            selectInd <- r$selectors |>
                dplyr::filter(tag_id == input$tag_id)
            if (nrow(selectInd)) {
                updateSliderInput(
                    session,
                    "slider_date",
                    min = selectInd$min,
                    max = selectInd$max,
                    value = selectInd$max,
                    timeFormat = "%F" 
                )
            }
        })

        observe({
            r$max_date <- input$slider_date
        })
    })
}
