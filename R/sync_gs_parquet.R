#' Write Parquet Tracks to a GCS Bucket
#'
#' @description 
#' This function writes Parquet files containing animal tracks into a specified Google Cloud Storage (GCS) bucket. 
#' It partitions the data by `vernacular` and `tag_id` and handles authentication using a JSON credentials file.
#'
#' @param bucket Character. The name of the GCS bucket where Parquet files will be uploaded. 
#' @param auth_gcs_file_path Character. The path to the GCS JSON credentials file (default: `"./google_api_key.json"`).
#' @param ... Additional arguments passed to the `get_mb_tracks` function.
#'
#' @details
#' The function:
#' 1. Generates a temporary directory for storing the Parquet files.
#' 2. Writes datasets partitioned by `vernacular` and `tag_id` into the temporary directory.
#' 3. Authenticates with Google Cloud using the specified JSON credentials.
#' 4. Uploads the generated Parquet files to the specified GCS bucket.
#' 5. Cleans up temporary files on exit. 
#'
#' @export 
sync_gs_parquet <- function(bucket=NULL, auth_gcs_file_path="./google_api_key.json", ...){

  temp_parquet <- tempfile()

  arrow::write_dataset(
    get_mb_tracks(...),
    temp_parquet,
    basename_template = "part-{i}.parquet",
    format = "parquet",
    partitioning = c("vernacular", "tag_id"),
    existing_data_behavior = "overwrite"
  )

  googleCloudStorageR::gcs_auth(auth_gcs_file_path)

  parquet_files <- list.files(temp_parquet, recursive = TRUE)

  parquet_files |> purrr::walk(\(f) {
    googleCloudStorageR::gcs_upload(file.path(temp_parquet, f), name = f, bucket = bucket, predefinedAcl = "bucketLevel")
  })

  on.exit(file.remove(temp_parquet))
}
