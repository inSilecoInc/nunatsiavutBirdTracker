# nunatsiavutBirdTracker
[![Build and Release](https://github.com/inSilecoInc/nunatsiavutBirdTracker/actions/workflows/build-docker-container.yaml/badge.svg)](https://github.com/inSilecoInc/nunatsiavutBirdTracker/actions/workflows/build-docker-container.yaml)
[![R CMD Check](https://github.com/inSilecoInc/nunatsiavutBirdTracker/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/inSilecoInc/nunatsiavutBirdTracker/actions/workflows/R-CMD-check.yaml)

**nunatsiavutBirdTracker** is an application designed to explore the movements of gulls and eiders using Movebank data.

---

## Run the Shiny Application

Install the package and run the development version of the Shiny application locally:

```r
install.packages("pak")
pak::pak("inSilecoInc/nunatsiavutBirdTracker")
source("dev/run_dev.R")
```

## Birds metadata synchronization task

### Run the sync bird metadata task locally

```r
nunatsiavutBirdTracker::sync_gs_metadata(bucket="bird-metadata", auth_gcs_file_path="google_api_key.json")
```

### Sync bird metadata google metadata task

Declare the task

```r
gcloud run jobs create sync-bird-metadata \
    --region=us-central1 \
    --project nunatsiavut-birds \
    --image=northamerica-northeast1-docker.pkg.dev/nunatsiavut-birds/insileco/nunatsiavut-bird-tracker:latest \
    --command=/bin/bash \
    --args="^@^-c@echo 'Starting the task execution...' && cd /srv/shiny-server && Rscript -e \"print('R script is starting'); nunatsiavutBirdTracker::sync_gs_metadata(bucket='bird-metadata', auth_gcs_file_path='google_api_key.json'); print('R script completed')\" && echo 'Task execution completed successfully.'" \
    --cpu=1 \
    --memory=512Mi \
    --max-retries=3
```

Set the schedule

```r
gcloud scheduler jobs create http sync-bird-metadata-scheduled \
    --project nunatsiavut-birds \
    --oauth-service-account-email=run-scheduled-jobs@nunatsiavut-birds.iam.gserviceaccount.com \
    --schedule="*/30 * * * *" \
    --uri="https://us-central1-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/nunatsiavut-birds/jobs/sync-data-gulls:run" \
    --http-method=POST \
    --headers="Content-Type=application/json" \
    --location=us-central1
```

## Bird locations synchronization task

The package includes a function, `sync_gs_parquet`, to download data from Movebank, format it as Parquet files, and upload them to Google Cloud Storage (GCS).

**Note:** It is recommended to use the Docker container to run the synchronization task because it includes:

- The Google service account key for uploading data to the S3 bucket.
- The credentials required for Movebank API calls.

If running the task locally:

Add the Google service account key (`google_api_key.json`) to the root of the repository.
Configure a `.Renviron` file with your Movebank credentials (`MOVEBANK_USERNAME` and `MOVEBANK_PASSWORD`).

### Run the sync bird locations task locally

 The function `sync_gs_parquet` writes the data in Parquet format locally and uploads each Parquet partition file to an S3 bucket.

#### Eiders study project

```r
nunatsiavutBirdTracker::sync_gs_parquet(bucket="bird-locations", auth_gcs_file_path="google_api_key.json", study_id = 4036904918)
```

#### Gulls study project

```r
nunatsiavutBirdTracker::sync_gs_parquet(bucket="bird-locations", auth_gcs_file_path="google_api_key.json", study_id = 2854587542)
```

### Run the sync locations containerized task

Build the docker image

```sh
docker build -t nunatsiavut-bird-tracker . ; docker run -it --rm --network host nunatsiavut-bird-tracker
```

Run the sync function within the docker

```sh
docker run -it nunatsiavut-bird-tracker bash -c "cd /srv/shiny-server/ && Rscript -e 'nunatsiavutBirdTracker::sync_gs_parquet(bucket='bird-locations', auth_gcs_file_path='google_api_key.json', study_id = <MOVEBANK_STUDY_ID> )'"
```

`<MOVEBANK_STUDY_ID>` corresponds to the movebank project ID which contains birds locations. The function `sync_gs_parquet` will retrieve and write all bird locations on the google S3 bucket.

Replace `<MOVEBANK_STUDY_ID>` with:

- 4036904918 for Eiders
- 2854587542 for Gulls


### Run on Google cloud as scheduled task 

#### Login

```sh
gcloud auth login
```

**Note:** Install the gcloud CLI client following https://cloud.google.com/sdk/docs/install

#### Declare Gulls sync job

```sh
gcloud run jobs create sync-data-gulls \
    --region=us-central1 \
    --project nunatsiavut-birds \
    --image=northamerica-northeast1-docker.pkg.dev/nunatsiavut-birds/insileco/nunatsiavut-bird-tracker:latest \
    --command=/bin/bash \
    --args="^@^-c@echo 'Starting the task execution...' && cd /srv/shiny-server && Rscript -e \"print('R script is starting'); nunatsiavutBirdTracker::sync_gs_parquet(bucket='bird-locations', auth_gcs_file_path='google_api_key.json', study_id=2854587542); print('R script completed')\" && echo 'Task execution completed successfully.'" \
    --cpu=1 \
    --memory=1024Mi \
    --max-retries=3
```

#### Set Gulls CRON job

```sh
gcloud scheduler jobs create http sync-data-gulls-scheduled \
    --project nunatsiavut-birds \
    --oauth-service-account-email=run-scheduled-jobs@nunatsiavut-birds.iam.gserviceaccount.com \
    --schedule="*/30 * * * *" \
    --uri="https://us-central1-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/nunatsiavut-birds/jobs/sync-data-gulls:run" \
    --http-method=POST \
    --headers="Content-Type=application/json" \
    --location=us-central1
```

#### Declare Eiders sync job

```sh
gcloud run jobs create sync-data-eiders \
    --region=us-central1 \
    --project nunatsiavut-birds \
    --image=northamerica-northeast1-docker.pkg.dev/nunatsiavut-birds/insileco/nunatsiavut-bird-tracker:latest \
    --command=/bin/bash \
    --args="^@^-c@echo 'Starting the task execution...' && cd /srv/shiny-server && Rscript -e \"print('R script is starting'); nunatsiavutBirdTracker::sync_gs_parquet(bucket='bird-locations', auth_gcs_file_path='google_api_key.json', study_id=4036904918); print('R script completed')\" && echo 'Task execution completed successfully.'" \
    --cpu=1 \
    --memory=512Mi \
    --max-retries=3
```

#### Set Eiders CRON job

```sh
gcloud scheduler jobs create http sync-data-eiders-scheduled \
    --project nunatsiavut-birds \
    --oauth-service-account-email=run-scheduled-jobs@nunatsiavut-birds.iam.gserviceaccount.com \
    --schedule="*/30 * * * *" \
    --uri="https://us-central1-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/nunatsiavut-birds/jobs/sync-data-eiders:run" \
    --http-method=POST \
    --headers="Content-Type=application/json" \
    --location="us-central1"
```

### Contributing

Please follow the guidelines described [here](https://github.com/inSilecoInc/iseShinyTemplate?tab=readme-ov-file#code-convention).


### Shiny references

1. https://mastering-shiny.org/index.html
2. https://engineering-shiny.org/
3. https://unleash-shiny.rinterface.com/

