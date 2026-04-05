# =============================================================================
# IAM — Cloud Functions Service Account
# GCP equivalent of: AWS IAM Lambda Execution Role
#
# NOTE: Workload Identity Federation (WIF) and GitHub Actions SA are
# bootstrapped manually via gcloud (chicken-and-egg problem).
# This module only manages the Cloud Functions runtime SA.
# =============================================================================

# 1. Service Account for Cloud Functions
# Equivalent to AWS Lambda Execution Role
resource "google_service_account" "cloud_functions" {
  account_id   = "${var.project_name}-cf-sa"
  display_name = "${var.project_name} Cloud Functions Service Account"
  project      = var.project_id
}

# 2. Grant Firestore access (equivalent to DynamoDB permissions)
resource "google_project_iam_member" "firestore_user" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.cloud_functions.email}"
}

# 3. Grant Cloud Logging access (equivalent to CloudWatch Logs)
resource "google_project_iam_member" "log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloud_functions.email}"
}

# 4. Grant Secret Manager access (for SendGrid API key)
resource "google_project_iam_member" "secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.cloud_functions.email}"
}