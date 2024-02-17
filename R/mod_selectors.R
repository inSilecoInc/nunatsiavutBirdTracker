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
        selectInput(ns("species"), label = "Choose the species", choices = get_species_list()),
        selectInput(ns("tag_id"), label = "Choose your favorite bird", choices = get_individus_list()),
        uiOutput(ns("slider"))
    )
}

#' select_map Server Functions
#'
#' @noRd
mod_selectors_server <- function(id, r) {
    moduleServer(id, function(input, output, session) {
        ns <- session$ns

        output$slider <- renderUI({
            window <- ind_temporal_window(input$tag_id)
            sliderInput("slider", "Period", min = window$min, max = window$max, value = c(window$min, window$max))
        })

        observeEvent(input$tag_id, {
            window <- ind_temporal_window(input$tag_id)
            updateSliderInput(session, "slider", min = window$min, max = window$max, value = c(window$min, window$max))
        })

        observeEvent(input$species, {
            updateSelectInput(session, "tag_id",
                choices = get_individus_list(species = input$species)
            )
        })
    })
}
