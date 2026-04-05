# =============================================================================
# IAM — Service Accounts & Build Permissions
# GCP equivalent of: AWS IAM Lambda Execution Role
#
# NOTE: Workload Identity Federation (WIF) and GitHub Actions SA are
# bootstrapped manually via gcloud (chicken-and-egg problem).
# This module manages:
#   1. Cloud Functions runtime SA
#   2. Cloud Build SA permissions (required for Cloud Functions 2nd Gen)
# =============================================================================

# ---------------------------------------------------------------------------
# 1. Cloud Functions Runtime Service Account
# ---------------------------------------------------------------------------
resource "google_service_account" "cloud_functions" {
  account_id   = "${var.project_name}-cf-sa"
  display_name = "${var.project_name} Cloud Functions Service Account"
  project      = var.project_id
}

# Firestore access (equivalent to DynamoDB permissions)
resource "google_project_iam_member" "firestore_user" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.cloud_functions.email}"
}

# Cloud Logging access (equivalent to CloudWatch Logs)
resource "google_project_iam_member" "log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloud_functions.email}"
}

# Secret Manager access (for SendGrid API key)
resource "google_project_iam_member" "secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.cloud_functions.email}"
}

# ---------------------------------------------------------------------------
# 2. Cloud Build Service Account Permissions
#    Cloud Functions 2nd Gen uses Cloud Build to build container images.
#    The default Cloud Build SA needs explicit permissions since GCP
#    changed the default policy (Feb 2024+).
#    Reference: https://cloud.google.com/functions/docs/troubleshooting#build-service-account
# ---------------------------------------------------------------------------

# Fetch project metadata to get the project number dynamically
data "google_project" "current" {
  project_id = var.project_id
}

locals {
  cloud_build_sa = "${data.google_project.current.number}@cloudbuild.gserviceaccount.com"
  compute_sa     = "${data.google_project.current.number}-compute@developer.gserviceaccount.com"
}

# Cloud Build SA: Allow building container images
resource "google_project_iam_member" "cloudbuild_builder" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.builder"
  member  = "serviceAccount:${local.cloud_build_sa}"
}

# Cloud Build SA: Allow writing to Artifact Registry (stores built images)
resource "google_project_iam_member" "cloudbuild_ar_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${local.cloud_build_sa}"
}

# Cloud Build SA: Allow reading source code from GCS
resource "google_project_iam_member" "cloudbuild_storage_viewer" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${local.cloud_build_sa}"
}

# Cloud Build SA: Allow logging build output
resource "google_project_iam_member" "cloudbuild_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${local.cloud_build_sa}"
}

# Default Compute SA: Allow Cloud Functions to pull built images
resource "google_project_iam_member" "compute_ar_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${local.compute_sa}"
}