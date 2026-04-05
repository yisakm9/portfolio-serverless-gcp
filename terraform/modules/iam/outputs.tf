output "cloud_functions_sa_email" {
  description = "Email of the Cloud Functions service account"
  value       = google_service_account.cloud_functions.email
}