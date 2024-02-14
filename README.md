# iseShinyTemplate
[![build-and-release](https://github.com/inSilecoInc/iseShinyTemplate/actions/workflows/build-docker-container.yaml/badge.svg)](https://github.com/inSilecoInc/iseShinyTemplate/actions/workflows/build-docker-container.yaml)
[![R CMD Check](https://github.com/inSilecoInc/iseShinyTemplate/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/inSilecoInc/iseShinyTemplate/actions/workflows/R-CMD-check.yaml)


Shiny application template, built with the [Golem](https://github.com/ThinkR-open/golem) framework.


## How to use the template 

Start your project with this template. 

### Make sure it works

```R
install.packages("pak")
pak::pak("inSilecoInc/iseShinyTemplate")
source("dev/run_dev.R")
```

### Use it

Replace `iseShinyTemplate` with your package name. This includes the following files:

- `DESCRIPTION`
- `dev/*`
- `Dockerfile`
- `R/app_config.R`
- `R/app_cui.R`

### Code convention

#### Code style

Code styling adheres to the tidyverse convention available in detail at https://style.tidyverse.org/. Because we do not use functional pipes in shiny UI and server functions, we indent each by 4 spaces instead of 2.

Code can be formatted by simply applying the following function:

```r
styler::style_pkg(style = styler::tidyverse_style(), transformers = styler::tidyverse_style(indent_by = 4))
```

#### Naming function

Variables and functions are declared using snake cases to easily differentiate shiny functions from the rest of the application.

#### Users notifications 

We use classic shiny notifications for short processing steps.

```r
ntf_id <- showNotification(
    "Rendering HTML preview...",
    duration = NULL,
    closeButton = TRUE
)
```
For ideas and good practices about users feedback, have a look at [this book section](https://mastering-shiny.org/action-feedback.html?q=notifications#notifications).


#### Logging backend 

We use the `cli` package to provide logging information that might be relevant for investigations (bugs, performance issues).
Module names must be prefixed in log messages, as follows:

```r
observeEvent(input$reset_view, {
    cli::cli_alert_info("Map - Resetting map view to default")
    r$map <- reset_view(r$map)
})
```
Timestamps should not be prefixed at the log entry level. The shiny server is responsible for this. 
For verbosity controls, read [this rOpenSci blog post](https://ropensci.org/blog/2024/02/06/verbosity-control-packages/).

### Docker image 

```sh
docker build -t iseshinytemplate . ; docker run -it --rm --network host iseshinytemplate
```

⚠️ Known issue: chromium has not been added to the image (to make it lighter), 
so we cannot generate pdf.


### References

1. https://mastering-shiny.org/index.html
2. https://engineering-shiny.org/
3. https://unleash-shiny.rinterface.com/
