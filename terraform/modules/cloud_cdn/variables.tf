variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "gcs_bucket_name" {
  description = "Name of the GCS bucket to serve as backend"
  type        = string
}

variable "domain_names" {
  description = "List of domain names for the SSL certificate"
  type        = list(string)
  default     = []
}

variable "labels" {
  description = "Labels to apply"
  type        = map(string)
  default     = {}
}
