## code to prepare `nunatsiavut_gulls` dataset goes here
nunatsiavut_gulls <- read.csv(system.file("extdata", "nunatsiavut_gulls_14022024.csv", package = "nunatsiavutBirdTracker"))
usethis::use_data(nunatsiavut_gulls, overwrite = TRUE)
