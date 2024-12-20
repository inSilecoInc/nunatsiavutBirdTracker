#' bird_description UI Function
#'
#' @description This module displays various informations on the individual bird selected
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
mod_bird_description_ui <- function(id){
  ns <- NS(id)
  uiOutput(ns("description"))
}
    
#' bird_description Server Functions
#'
#' @noRd 
mod_bird_description_server <- function(id, r){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    observeEvent(r$tag_id, {
      req(r$tag_id, birds_metadata)
      selDesc <- dplyr::filter(birds_metadata, tag_id == r$tag_id)
      r$selectedBirdDescription <- selDesc

      googleCloudStorageR::gcs_auth("./google_api_key.json")

      # Set photos
      bucketName <- "assets-photos"
      gcs_photos <- googleCloudStorageR::gcs_list_objects(bucket = bucketName, prefix = r$tag_id) 
      
      if(nrow(gcs_photos) > 0) {
        photos <- gcs_photos |> dplyr::pull(name) |>
        googleCloudStorageR::gcs_download_url(bucket = bucketName, public = TRUE)
      } else if(selDesc$species == "Somateria mollissima") {
        photos <- "https://images.phylopic.org/images/6db76232-0ff7-4599-a8c8-0070fd7dd51c/vector.svg"
      } else if(stringr::str_detect(selDesc$species, "Larus")) {
        photos <- "https://images.phylopic.org/images/6f87dbf2-289a-4c57-b26c-9384993c37d4/vector.svg"
      } else {
        photos <- "https://upload.wikimedia.org/wikipedia/commons/thumb/2/25/Icon-round-Question_mark.jpg/600px-Icon-round-Question_mark.jpg?20100222190926"
      }
   
      output$description <- renderUI({
        bslib::card(
          bslib::card_body(
              h4(
                ifelse(is.na(selDesc$name), "Unnamed bird", stringr::str_to_title(selDesc$name)),
                br(),
                span(class="text-muted", style="font-size: .7em;", selDesc$vernacular_en),
                br(),
                span(class="fst-italic", style="font-size: .7em;", selDesc$species),
                br(),
                span(class="badge rounded-pill bg-primary fw-lighter", paste("#Tag ID - ", selDesc$tag_id),  style="font-size: .5em;")
              ),
              slickR::slickR(obj = photos, height=300, width = "95%", padding = 10) + slickR::settings(dots = TRUE),
              tagList(
                tags$ul(class="list-group list-group-flush",
                  tags$li(class = "list-group-item", 
                    p(span("Sex", class="fw-bold"), 
                    dplyr::case_when(
                      selDesc$sex == "M" ~ "Male",
                      selDesc$sex == "F" ~ "Female",
                      TRUE ~ "Unknown"
                    ))
                  ),
                  tags$li(class = "list-group-item", 
                    p(span("GPS deployment date", class="fw-bold"), selDesc$tag_deployment_date)
                  ),
                  tags$li(class = "list-group-item", 
                    p(span("Colony name", class="fw-bold"), selDesc$colony_name)
                  ),
                  tags$li(class = "list-group-item", 
                    p(span("Departure from breeding area", class="fw-bold"), selDesc$departure_date_from_breeding_area)
                  ),
                  tags$li(class = "list-group-item", 
                    p(span("Arrival from wintering area", class="fw-bold"), selDesc$arrival_date_to_wintering_area)
                  ),
                  tags$li(class = "list-group-item", 
                    p(span("Fun fact", class="fw-bold"), selDesc$fun_fact)
                  )
                )
              )
          ),
          class="border border-0",
          fill = FALSE
        )
      })
    })

  })
}
