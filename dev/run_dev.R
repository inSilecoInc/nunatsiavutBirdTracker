# Set options here
options(golem.app.prod = FALSE) # TRUE = production mode, FALSE = development mode
# Detach all loaded packages and clean your environment
golem::detach_all_attached()
# rm(list=ls(all.names = TRUE))
# Document and reload your package
golem::document_and_reload()
# Run the application
Sys.setenv(GOOGLE_APPLICATION_CREDENTIALS="./google_api_key.json")
run_app(options = list(port = 5000, host = "0.0.0.0"))
