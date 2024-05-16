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
          img(src = "www/img/201642.png", class = "img-fluid", alt = "Test"),
          bslib::card_title("Description"),
          lorem::ipsum(paragraphs = 1)
      ),
      class="border border-0"
  )
}
    
#' bird_description Server Functions
#'
#' @noRd 
mod_bird_description_server <- function(id, r){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
 
  })
}
