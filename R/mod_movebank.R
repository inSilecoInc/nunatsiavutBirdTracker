#' selectors UI Function
#'
#' @description A shiny Module to create spatial objects.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
mod_movebank_ui <- function(id) {
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
mod_movebank_server <- function(id, r) {
    moduleServer(id, function(input, output, session) {
        ns <- session$ns

        study_id <- 2854587542
        movebank <- reactiveValues(
            individus = fetch_movebank_study_points(study_id),
            tracks = fetch_movebank_study_tracks(study_id)
        )
    
        observe({
            updateSelectInput(session, "vernacular", choices = movebank$individus$metadata$vernacular |> unique())
            updateSelectInput(session, "tag_id", choices = movebank$individus$metadata$tag_id)
        })

        observeEvent(input$vernacular, {
            tag_ids <- dplyr::filter(movebank$individus$metadata, vernacular == input$vernacular)$tag_id
            updateSelectInput(session, "tag_id", choices = tag_ids)
        })

        output$slider <- renderUI({
            window <- dplyr::filter(movebank$individus$metadata, tag_id == input$tag_id)
            print(window)
            sliderInput("slider", "Period", step = 3600, min = window$min, max = window$max, value = c(window$min, window$max))
        })

        observeEvent(input$tag_id, {
            window <- dplyr::filter(movebank$individus$metadata, tag_id == input$tag_id)
            updateSliderInput(session, "slider", min = window$min, max = window$max, value = c(window$min, window$max))
        })
    })
}
