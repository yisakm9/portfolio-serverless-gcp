# Terraform state stored in GCS (equivalent to S3 backend)
terraform {
  backend "gcs" {
    bucket = "yisak-portfolio-tf-state"
    prefix = "terraform/state"
  }
}