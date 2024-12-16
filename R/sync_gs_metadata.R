#' Upload Bird Metadata to GCS Bucket
#'
#' @description
#' This function reads bird metadata from a Google Sheets document, cleans the column names,
#' saves the data as an RDS file, and uploads it to a specified Google Cloud Storage (GCS) bucket.
#'
#' @param bucket Character. The name of the GCS bucket where the RDS file will be uploaded. Cannot be `NULL`.
#' @param auth_gcs_file_path Character. The path to the GCS JSON credentials file. Default is `"./google_api_key.json"`.
#'
#' @export
sync_gs_metadata <- function(bucket=NULL, auth_gcs_file_path="./google_api_key.json"){
    birds_md <- googlesheets4::read_sheet("https://docs.google.com/spreadsheets/d/1XiksWymZ8Mam9moxwTxwkK5UzuQ5KDzZRahdr72V-oM/edit?usp=sharing") |>
        janitor::clean_names()

    tmp_rds <- tempfile(fileext = ".rds")
    saveRDS(birds_md, tmp_rds)

    googleCloudStorageR::gcs_auth(auth_gcs_file_path)

    googleCloudStorageR::gcs_upload(tmp_rds, name = "bird-metadata.rds", bucket = bucket, predefinedAcl = "bucketLevel")
    
  on.exit(file.remove(tmp_rds))
}
