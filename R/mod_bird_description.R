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
  uiOutput(ns("description"))
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
      req(r$tag_id, birds_metadata)
      selDesc <- dplyr::filter(birds_metadata, tag_id == r$tag_id)
      print(names(selDesc))
      r$selectedBirdDescription <- selDesc
      output$description <- renderUI({
        bslib::card(
          bslib::card_body(
              h4(
                ifelse(is.na(selDesc$name), "Unnamed bird", stringr::str_to_title(selDesc$name)),
                br(),
                span(class="text-muted", style="font-size: .7em;", "Glaucus Gull"),
                br(),
                span(class="fst-italic", style="font-size: .7em;", "Larus glaucoides"),
                br(),
                span(class="badge rounded-pill bg-primary fw-lighter", paste("#Tag ID - ", selDesc$tag_id),  style="font-size: .5em;")
              ),
              img(src = "www/img/201642.png", class = "figure-img img-fluid rounded w-75", alt = "Test"),
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
