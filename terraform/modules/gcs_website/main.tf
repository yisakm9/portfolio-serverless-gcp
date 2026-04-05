# =============================================================================
# GCS Website Bucket — Static Frontend Hosting
# GCP equivalent of: AWS S3 Website Bucket + S3 Access Policy
# =============================================================================

# 1. Create the GCS Bucket for static site files
resource "google_storage_bucket" "website" {
  name          = var.bucket_name
  location      = var.region
  project       = var.project_id
  force_destroy = true # Allow terraform destroy to delete non-empty bucket

  # Uniform bucket-level access (recommended over ACLs)
  uniform_bucket_level_access = true

  # Versioning (safety best practice)
  versioning {
    enabled = true
  }

  # Website configuration for SPA
  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html" # SPA fallback — same as CloudFront custom error response
  }

  # CORS configuration for API calls
  cors {
    origin          = var.allowed_origins
    method          = ["GET", "HEAD"]
    response_header = ["Content-Type"]
    max_age_seconds = 3600
  }

  labels = var.labels
}

# 2. Make bucket publicly readable (required for CDN backend bucket)
# This replaces the S3 bucket policy + CloudFront OAC pattern
resource "google_storage_bucket_iam_member" "public_read" {
  bucket = google_storage_bucket.website.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}
