# =============================================================================
# Root Module — Orchestrates all GCP resources
# GCP equivalent of the AWS main.tf that wired S3, CloudFront, Lambda, etc.
# =============================================================================

# Random suffix for globally unique bucket names
resource "random_pet" "suffix" {
  length = 2
}

# =============================================================================
# 1. STATIC HOSTING — GCS Bucket (replaces S3 + S3 Access Policy)
# =============================================================================
module "frontend_bucket" {
  source = "../../modules/gcs_website"

  bucket_name = "${var.project_name}-frontend-${var.environment}-${random_pet.suffix.id}"
  project_id  = var.project_id
  region      = var.gcp_region

  labels = {
    environment = var.environment
    type        = "frontend"
  }
}

# =============================================================================
# 2. CDN + LOAD BALANCER (replaces CloudFront)
# =============================================================================
module "cloud_cdn" {
  source = "../../modules/cloud_cdn"

  project_name    = var.project_name
  project_id      = var.project_id
  environment     = var.environment
  gcs_bucket_name = module.frontend_bucket.bucket_name

  # Custom domain for SSL certificate
  domain_names = [var.domain_name, "www.${var.domain_name}"]
}

# =============================================================================
# 3. DATABASE — Firestore (replaces DynamoDB)
# The import block handles the case where the (default) database already exists
# in GCP (it can't be truly deleted). On fresh deploys, Terraform imports it
# instead of failing with a 409 error.
# =============================================================================
import {
  to = module.firestore.google_firestore_database.default
  id = "projects/${var.project_id}/databases/(default)"
}

module "firestore" {
  source = "../../modules/firestore"

  project_id = var.project_id
  region     = "nam5" # US multi-region for Firestore
}

# =============================================================================
# 4. IAM — Cloud Functions Service Account (replaces IAM Lambda Role)
# NOTE: WIF + GitHub Actions SA are bootstrapped via gcloud (see README)
# =============================================================================
module "iam" {
  source = "../../modules/iam"

  project_name = var.project_name
  project_id   = var.project_id
}

# =============================================================================
# 5. CLOUD FUNCTION — Contact Form (replaces Lambda contact + API Gateway)
# =============================================================================
module "cloud_function_contact" {
  source = "../../modules/cloud_function"

  function_name         = "${var.project_name}-contact-${var.environment}"
  project_name          = var.project_name
  project_id            = var.project_id
  region                = var.gcp_region
  environment           = var.environment
  description           = "Contact form handler — saves to Firestore and sends email via SendGrid"
  source_dir            = "${path.module}/../../../backend/contact_form"
  entry_point           = "handle_contact"
  service_account_email = module.iam.cloud_functions_sa_email

  environment_variables = {
    GCP_PROJECT     = var.project_id
    SENDER_EMAIL    = var.sender_email
    SENDGRID_SECRET = "sendgrid-api-key"
  }

  labels = {
    environment = var.environment
    function    = "contact-form"
  }

  depends_on = [module.firestore, module.iam]
}

# =============================================================================
# 6. CLOUD FUNCTION — Get Projects (replaces Lambda get_projects + API Gateway)
# =============================================================================
module "cloud_function_projects" {
  source = "../../modules/cloud_function"

  function_name         = "${var.project_name}-projects-${var.environment}"
  project_name          = var.project_name
  project_id            = var.project_id
  region                = var.gcp_region
  environment           = var.environment
  description           = "Fetches GitHub repositories for the portfolio"
  source_dir            = "${path.module}/../../../backend/get_projects"
  entry_point           = "handle_projects"
  service_account_email = module.iam.cloud_functions_sa_email

  environment_variables = {
    GITHUB_USERNAME = "yisakm9"
  }

  labels = {
    environment = var.environment
    function    = "get-projects"
  }

  depends_on = [module.iam]
}

# =============================================================================
# 7. MONITORING — Cloud Monitoring Dashboard (replaces CloudWatch)
# =============================================================================
module "monitoring" {
  source = "../../modules/monitoring"

  project_name          = var.project_name
  project_id            = var.project_id
  environment           = var.environment
  contact_function_name = module.cloud_function_contact.function_name
  url_map_name          = module.cloud_cdn.url_map_name
}

# =============================================================================
# 8. SECRET MANAGER — SendGrid API Key (replaces SES config)
# =============================================================================
resource "google_secret_manager_secret" "sendgrid_api_key" {
  secret_id = "sendgrid-api-key"
  project   = var.project_id

  replication {
    auto {}
  }

  labels = {
    environment = var.environment
    purpose     = "email"
  }
}

# =============================================================================
# 9. CLOUDFLARE DNS — Automated Domain Management (replaces manual curl/UI)
# Creates/destroys DNS records alongside infrastructure
# =============================================================================
module "cloudflare_dns" {
  source = "../../modules/cloudflare"

  domain_name      = var.domain_name
  load_balancer_ip = module.cloud_cdn.load_balancer_ip
}