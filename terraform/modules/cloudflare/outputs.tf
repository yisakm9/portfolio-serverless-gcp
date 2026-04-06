output "root_record_hostname" {
  description = "The root domain A record hostname"
  value       = cloudflare_record.root.hostname
}

output "www_record_hostname" {
  description = "The www subdomain A record hostname"
  value       = cloudflare_record.www.hostname
}

output "zone_id" {
  description = "The Cloudflare zone ID"
  value       = data.cloudflare_zone.domain.id
}
