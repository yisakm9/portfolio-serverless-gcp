variable "project_id" {
  description = "The GCP project ID"
  type        = string
  default     = "project-6cdce5b2-1881-424f-a94"
}

variable "gcp_region" {
  description = "The GCP region to deploy resources into"
  type        = string
  default     = "us-central1"
}

variable "project_name" {
  description = "Project naming convention"
  type        = string
  default     = "yisak-portfolio"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "domain_name" {
  description = "Custom domain name"
  type        = string
  default     = "yisakmesifin.org"
}

variable "sender_email" {
  description = "Email address for sending notifications"
  type        = string
  default     = "yisakmesifin@gmail.com"
}