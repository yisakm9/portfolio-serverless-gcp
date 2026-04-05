# =============================================================================
# Cloud Functions 2nd Gen — Serverless Functions
# GCP equivalent of: AWS Lambda + API Gateway
# Cloud Functions 2nd Gen have built-in HTTP triggers (no separate API GW needed)
# =============================================================================

# 1. GCS Bucket to store function source code (equivalent to Lambda zip upload)
resource "google_storage_bucket" "function_source" {
  name                        = "${var.project_name}-cf-source-${var.function_name}-${var.environment}"
  location                    = var.region
  project                     = var.project_id
  uniform_bucket_level_access = true
  force_destroy               = true

  labels = var.labels
}

# 2. Zip and upload source code
data "archive_file" "function_zip" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = "${path.module}/${var.function_name}.zip"
}

resource "google_storage_bucket_object" "function_source" {
  name   = "${var.function_name}-${data.archive_file.function_zip.output_md5}.zip"
  bucket = google_storage_bucket.function_source.name
  source = data.archive_file.function_zip.output_path
}

# 3. Cloud Function (2nd Gen)
resource "google_cloudfunctions2_function" "this" {
  name     = var.function_name
  location = var.region
  project  = var.project_id

  description = var.description

  build_config {
    runtime     = "python312"
    entry_point = var.entry_point

    source {
      storage_source {
        bucket = google_storage_bucket.function_source.name
        object = google_storage_bucket_object.function_source.name
      }
    }
  }

  service_config {
    max_instance_count    = 10
    min_instance_count    = 0
    available_memory      = "256M"
    timeout_seconds       = 60
    service_account_email = var.service_account_email

    environment_variables = var.environment_variables
  }

  labels = var.labels
}

# 4. Allow unauthenticated access (public HTTP endpoint)
# Equivalent to API Gateway's open access
resource "google_cloud_run_v2_service_iam_member" "public_access" {
  name     = google_cloudfunctions2_function.this.service_config[0].service
  location = var.region
  project  = var.project_id
  role     = "roles/run.invoker"
  member   = "allUsers"
}
