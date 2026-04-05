variable "project_name" {
  description = "Project name"
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

variable "contact_function_name" {
  description = "Name of the contact form Cloud Function"
  type        = string
}

variable "url_map_name" {
  description = "Name of the URL map (for LB metrics)"
  type        = string
}