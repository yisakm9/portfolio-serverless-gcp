output "bucket_name" {
  description = "The name of the GCS bucket"
  value       = google_storage_bucket.website.name
}

output "bucket_url" {
  description = "The URL of the GCS bucket"
  value       = google_storage_bucket.website.url
}

output "bucket_self_link" {
  description = "The self_link of the GCS bucket (used by backend bucket)"
  value       = google_storage_bucket.website.self_link
}
