# environments/dev/provider.tf
terraform {
  required_version = ">= 1.13.1"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.gcp_region

  # Default labels apply to ALL resources (equivalent to AWS default_tags)
  default_labels = {
    project     = "yisak-portfolio"
    environment = "dev"
    managed_by  = "terraform"
    owner       = "yisak-mesifin"
  }
}

# Cloudflare provider — authenticates via CLOUDFLARE_API_TOKEN env var
# Set by: bootstrap.sh (locally) or GitHub Actions secret (CI/CD)
provider "cloudflare" {
  # Token is read from CLOUDFLARE_API_TOKEN environment variable automatically
}
