output "function_uri" {
  description = "The URI of the Cloud Function (HTTPS endpoint)"
  value       = google_cloudfunctions2_function.this.service_config[0].uri
}

output "function_name" {
  description = "The name of the Cloud Function"
  value       = google_cloudfunctions2_function.this.name
}

output "service_name" {
  description = "The underlying Cloud Run service name"
  value       = google_cloudfunctions2_function.this.service_config[0].service
}
