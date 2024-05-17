#' bird_description UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_bird_description_ui <- function(id){
  ns <- NS(id)
  bslib::card(
      bslib::card_body(
          h3("Michelle"),
          img(src = "www/img/201642.png", class = "figure-img img-fluid rounded", alt = "Test"),
          bslib::card_title("Fun fact"),
          p(textOutput(ns("selected_bird_metadata"))),
          div(class = "btn-group", role = "group",
            actionButton("previous", label = "Previous", class="btn btn-primary"),
            actionButton("next", label = "Next", class="btn btn-primary")
          )
      ),
      class="border border-0"
  )
}
    
#' bird_description Server Functions
#'
#' @noRd 
mod_bird_description_server <- function(id, r){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    googleCloudStorageR::gcs_auth(Sys.getenv("GOOGLE_APPLICATION_CREDENTIALS"))
    birds_metadata <- googleCloudStorageR::gcs_get_object("bird-metadata.rds",
      bucket = "bird-metadata", 
      parseFunction= googleCloudStorageR::gcs_parse_rds
    )

    observeEvent(r$tag_id, {
      output$selected_bird_metadata <- renderText({
        dplyr::filter(birds_metadata, tag_id == r$tag_id)$fun_fact
      })
    })

  })
}
