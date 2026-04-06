# =============================================================================
# Cloudflare DNS — Automated Domain Management
# Replaces manual curl/UI DNS record creation
#
# On terraform apply: Creates A records pointing to GCP Load Balancer
# On terraform destroy: Removes A records (clean teardown)
# =============================================================================

# Look up the zone by domain name
data "cloudflare_zone" "domain" {
  name = var.domain_name
}

# A record for root domain (@)
resource "cloudflare_record" "root" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "@"
  content = var.load_balancer_ip
  type    = "A"
  ttl     = 1  # Auto TTL
  proxied = false  # DNS-only — required for Google-managed SSL certificate provisioning

  comment = "Managed by Terraform — points to GCP Global Load Balancer"
}

# A record for www subdomain
resource "cloudflare_record" "www" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "www"
  content = var.load_balancer_ip
  type    = "A"
  ttl     = 1
  proxied = false

  comment = "Managed by Terraform — points to GCP Global Load Balancer"
}
