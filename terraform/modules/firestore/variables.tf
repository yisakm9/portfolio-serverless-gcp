variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "Firestore location (use multi-region like nam5 or single region)"
  type        = string
  default     = "nam5" # US multi-region
}
