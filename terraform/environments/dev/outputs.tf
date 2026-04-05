# =============================================================================
# Outputs — Key information for CI/CD and DNS configuration
# =============================================================================

# Frontend
output "frontend_bucket_name" {
  description = "The GCS bucket name for the frontend"
  value       = module.frontend_bucket.bucket_name
}

# Load Balancer / CDN
output "load_balancer_ip" {
  description = "The global static IP — Point Cloudflare DNS A record here"
  value       = module.cloud_cdn.load_balancer_ip
}

output "url_map_name" {
  description = "The URL map name (used for CDN cache invalidation)"
  value       = module.cloud_cdn.url_map_name
}

output "website_url" {
  description = "The public URL of your website"
  value       = "https://${var.domain_name}"
}

# Cloud Functions (API endpoints)
output "contact_function_url" {
  description = "The HTTPS endpoint for the contact form function"
  value       = module.cloud_function_contact.function_uri
}

output "projects_function_url" {
  description = "The HTTPS endpoint for the get projects function"
  value       = module.cloud_function_projects.function_uri
}

# Monitoring
output "monitoring_dashboard_url" {
  description = "Direct link to the Cloud Monitoring dashboard"
  value       = "https://console.cloud.google.com/monitoring/dashboards?project=${var.project_id}"
}