# =============================================================================
# IAM — Service Accounts & Build Permissions
# GCP equivalent of: AWS IAM Lambda Execution Role
#
# NOTE: Workload Identity Federation (WIF) and GitHub Actions SA are
# bootstrapped manually via gcloud (chicken-and-egg problem).
# This module manages:
#   1. Cloud Functions runtime SA
#   2. Cloud Build SA permissions (required for Cloud Functions 2nd Gen)
#   3. IAM propagation delay (GCP IAM is eventually consistent)
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

# Cloud Functions SA also needs Cloud Build permissions to build itself
resource "google_project_iam_member" "cf_sa_cloudbuild" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.builder"
  member  = "serviceAccount:${google_service_account.cloud_functions.email}"
}

resource "google_project_iam_member" "cf_sa_ar_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.cloud_functions.email}"
}

resource "google_project_iam_member" "cf_sa_storage_admin" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.cloud_functions.email}"
}

resource "google_project_iam_member" "cf_sa_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloud_functions.email}"
}

# ---------------------------------------------------------------------------
# 2. Cloud Build & Default Compute Service Account Permissions
#    Cloud Functions 2nd Gen uses Cloud Build under the hood.
#    Since GCP policy changes (2024+), these must be explicit.
# ---------------------------------------------------------------------------

data "google_project" "current" {
  project_id = var.project_id
}

locals {
  cloud_build_sa = "${data.google_project.current.number}@cloudbuild.gserviceaccount.com"
  compute_sa     = "${data.google_project.current.number}-compute@developer.gserviceaccount.com"
}

# Ensure the Cloud Build service identity exists
resource "google_project_service_identity" "cloudbuild" {
  provider = google
  project  = var.project_id
  service  = "cloudbuild.googleapis.com"
}

# Grant Cloud Build SA all required roles
resource "google_project_iam_member" "cloudbuild_builder" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.builder"
  member  = "serviceAccount:${local.cloud_build_sa}"
  depends_on = [google_project_service_identity.cloudbuild]
}

resource "google_project_iam_member" "cloudbuild_ar_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${local.cloud_build_sa}"
  depends_on = [google_project_service_identity.cloudbuild]
}

resource "google_project_iam_member" "cloudbuild_storage" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${local.cloud_build_sa}"
  depends_on = [google_project_service_identity.cloudbuild]
}

resource "google_project_iam_member" "cloudbuild_logs" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${local.cloud_build_sa}"
  depends_on = [google_project_service_identity.cloudbuild]
}

# Grant Default Compute SA (sometimes used as the build SA in newer projects)
resource "google_project_iam_member" "compute_cloudbuild" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.builder"
  member  = "serviceAccount:${local.compute_sa}"
}

resource "google_project_iam_member" "compute_ar_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${local.compute_sa}"
}

resource "google_project_iam_member" "compute_storage" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${local.compute_sa}"
}

# ---------------------------------------------------------------------------
# 3. IAM Propagation Delay
#    GCP IAM is eventually consistent. Wait 60s after granting roles
#    before Cloud Functions attempts to use them.
# ---------------------------------------------------------------------------
resource "time_sleep" "iam_propagation" {
  create_duration = "60s"

  depends_on = [
    google_project_iam_member.cloudbuild_builder,
    google_project_iam_member.cloudbuild_ar_writer,
    google_project_iam_member.cloudbuild_storage,
    google_project_iam_member.cloudbuild_logs,
    google_project_iam_member.compute_cloudbuild,
    google_project_iam_member.compute_ar_reader,
    google_project_iam_member.cf_sa_cloudbuild,
    google_project_iam_member.cf_sa_ar_writer,
    google_project_iam_member.cf_sa_storage_admin,
  ]
}