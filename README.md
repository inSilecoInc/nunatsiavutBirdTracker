# nunatsiavutBirdTracker
[![build-and-release](https://github.com/inSilecoInc/nunatsiavutBirdTracker/actions/workflows/build-docker-container.yaml/badge.svg)](https://github.com/inSilecoInc/nunatsiavutBirdTracker/actions/workflows/build-docker-container.yaml)
[![R CMD Check](https://github.com/inSilecoInc/nunatsiavutBirdTracker/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/inSilecoInc/nunatsiavutBirdTracker/actions/workflows/R-CMD-check.yaml)

Application to explore Gulls and Ptarmigan movements. 
**Delivery date:** March 31th 2024

### Run the shiny application

```R
install.packages("pak")
pak::pak("inSilecoInc/nunatsiavutBirdTracker")
source("dev/run_dev.R")
```

### Build and run the docker image 

```sh
docker build -t nunatsiavut-bird-tracker . ; docker run -it --rm --network host nunatsiavut-bird-tracker
```

### Contributing

Please follow the guidelines described [here](https://github.com/inSilecoInc/iseShinyTemplate?tab=readme-ov-file#code-convention).


### Shiny references

1. https://mastering-shiny.org/index.html
2. https://engineering-shiny.org/
3. https://unleash-shiny.rinterface.com/
