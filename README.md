# nunatsiavutBirdTracker
[![build-and-release](https://github.com/inSilecoInc/nunatsiavutBirdTracker/actions/workflows/build-docker-container.yaml/badge.svg)](https://github.com/inSilecoInc/nunatsiavutBirdTracker/actions/workflows/build-docker-container.yaml)
[![R CMD Check](https://github.com/inSilecoInc/nunatsiavutBirdTracker/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/inSilecoInc/nunatsiavutBirdTracker/actions/workflows/R-CMD-check.yaml)

Application to explore Gulls and Ptarmigan movements. 

## Run the shiny application

```R
install.packages("pak")
pak::pak("inSilecoInc/nunatsiavutBirdTracker")
source("dev/run_dev.R")
```

### Build and run the docker image 

```sh
docker build -t nunatsiavut-bird-tracker . ; docker run -it --rm --network host nunatsiavut-bird-tracker
```

## Sync bird locations from Movebank to google cloud storage

The package provides a function to download data from Movebank, format it, and then upload it to Google Cloud Storage. This process involves two functions: `nunatsiavutBirdTracker::get_mb_tracks` and `nunatsiavutBirdTracker::sync_gs_parquet`. The `get_mb_tracks` function retrieves and formats data from Movebank, while `sync_gs_parquet` writes the data in Parquet format locally and uploads each Parquet partition file to an S3 bucket.

### Eiders study project

```r
nunatsiavutBirdTracker::sync_gs_parquet(bucket="bird-locations", auth_gcs_file_path="./nunatsiavut-birds-f42790fd372b.json", study_id = 4036904918)
```

### Gulls study project

```r
nunatsiavutBirdTracker::sync_gs_parquet(bucket="bird-locations", auth_gcs_file_path="./nunatsiavut-birds-f42790fd372b.json", study_id = 2854587542)
```

### Contributing

Please follow the guidelines described [here](https://github.com/inSilecoInc/iseShinyTemplate?tab=readme-ov-file#code-convention).


### Shiny references

1. https://mastering-shiny.org/index.html
2. https://engineering-shiny.org/
3. https://unleash-shiny.rinterface.com/

