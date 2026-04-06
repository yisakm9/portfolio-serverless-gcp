output "cloud_functions_sa_email" {
  description = "Email of the Cloud Functions service account"
  value       = google_service_account.cloud_functions.email
}

output "iam_ready" {
  description = "Dependency marker — ensures IAM propagation is complete before functions deploy"
  value       = time_sleep.iam_propagation.id
}