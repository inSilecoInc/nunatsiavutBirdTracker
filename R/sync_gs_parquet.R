#' Write parquet tracks in GCS bucket 
#'
#' @description Write parquet files with animals tracks into the target GCS bucket. 
#'
#' @param bucket GCS bucket name.
#' @param auth_gcs_file_path movebank password.
#' @param ... arguments passed to get_mb_tracks function 
#'
#' @export 
sync_gs_parquet <- function(bucket=NULL, auth_gcs_file_path="./nunatsiavut-birds-f33436183827.json", ...){

  temp_parquet_gulls <- tempfile()

  arrow::write_dataset(
    get_mb_tracks(...),
    temp_parquet_gulls,
    basename_template = "part-{i}.parquet",
    format = "parquet",
    partitioning = c("vernacular", "tag_id"),
    existing_data_behavior = "overwrite"
  )

  googleCloudStorageR::gcs_auth(auth_gcs_file_path)

  parquet_files <- list.files(temp_parquet_gulls, recursive = TRUE)

  parquet_files |> purrr::walk(\(f) {
    googleCloudStorageR::gcs_upload(file.path(temp_parquet_gulls, f), name = f, bucket = bucket, predefinedAcl = "bucketLevel")
  })

  on.exit(file.remove(temp_parquet_gulls))
}
