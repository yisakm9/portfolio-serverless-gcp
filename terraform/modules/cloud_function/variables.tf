variable "function_name" {
  description = "Name of the Cloud Function"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "description" {
  description = "Description of the function"
  type        = string
  default     = ""
}

variable "source_dir" {
  description = "Path to the directory containing the function source code"
  type        = string
}

variable "entry_point" {
  description = "The name of the function to execute"
  type        = string
  default     = "handler"
}

variable "service_account_email" {
  description = "Service account email for the function"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables for the function"
  type        = map(string)
  default     = {}
}

variable "labels" {
  description = "Labels to apply"
  type        = map(string)
  default     = {}
}
