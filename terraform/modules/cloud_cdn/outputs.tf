output "load_balancer_ip" {
  description = "The global static IP address of the load balancer (point Cloudflare DNS here)"
  value       = google_compute_global_address.default.address
}

output "url_map_id" {
  description = "The URL map ID (used for CDN cache invalidation)"
  value       = google_compute_url_map.default.id
}

output "url_map_name" {
  description = "The URL map name (used for CDN cache invalidation)"
  value       = google_compute_url_map.default.name
}

output "ssl_certificate_id" {
  description = "The SSL certificate ID"
  value       = google_compute_managed_ssl_certificate.default.id
}
