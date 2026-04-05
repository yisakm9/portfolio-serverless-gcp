# =============================================================================
# Cloud CDN + Global HTTP(S) Load Balancer + Google-Managed SSL
# GCP equivalent of: AWS CloudFront Distribution
# =============================================================================

# 1. Reserve a Global Static IP (this is what Cloudflare DNS will point to)
resource "google_compute_global_address" "default" {
  name    = "${var.project_name}-lb-ip-${var.environment}"
  project = var.project_id
}

# 2. Backend Bucket (connects LB to GCS)
resource "google_compute_backend_bucket" "website" {
  name        = "${var.project_name}-backend-${var.environment}"
  project     = var.project_id
  bucket_name = var.gcs_bucket_name
  enable_cdn  = true

  # CDN Cache Policy (equivalent to CloudFront cache behavior)
  cdn_policy {
    cache_mode        = "CACHE_ALL_STATIC"
    default_ttl       = 3600   # 1 hour (same as CloudFront default_ttl)
    max_ttl           = 86400  # 24 hours (same as CloudFront max_ttl)
    client_ttl        = 3600
    negative_caching  = true

    # Serve compressed content
    request_coalescing = true
  }
}

# 3. URL Map (routes requests to the backend bucket)
resource "google_compute_url_map" "default" {
  name            = "${var.project_name}-url-map-${var.environment}"
  project         = var.project_id
  default_service = google_compute_backend_bucket.website.id

  # SPA fallback — equivalent to CloudFront custom_error_response
  # GCP handles this via the GCS bucket's website config (not_found_page = index.html)
}

# 4. Google-Managed SSL Certificate for custom domain
resource "google_compute_managed_ssl_certificate" "default" {
  name    = "${var.project_name}-ssl-${var.environment}"
  project = var.project_id

  managed {
    domains = var.domain_names
  }
}

# 5. HTTPS Target Proxy
resource "google_compute_target_https_proxy" "default" {
  name             = "${var.project_name}-https-proxy-${var.environment}"
  project          = var.project_id
  url_map          = google_compute_url_map.default.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default.id]
}

# 6. HTTP Target Proxy (for redirect to HTTPS)
resource "google_compute_url_map" "http_redirect" {
  name    = "${var.project_name}-http-redirect-${var.environment}"
  project = var.project_id

  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}

resource "google_compute_target_http_proxy" "default" {
  name    = "${var.project_name}-http-proxy-${var.environment}"
  project = var.project_id
  url_map = google_compute_url_map.http_redirect.id
}

# 7. Global Forwarding Rules (the actual listeners)
# HTTPS (port 443)
resource "google_compute_global_forwarding_rule" "https" {
  name                  = "${var.project_name}-https-rule-${var.environment}"
  project               = var.project_id
  target                = google_compute_target_https_proxy.default.id
  port_range            = "443"
  ip_address            = google_compute_global_address.default.id
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

# HTTP (port 80) — redirects to HTTPS
resource "google_compute_global_forwarding_rule" "http" {
  name                  = "${var.project_name}-http-rule-${var.environment}"
  project               = var.project_id
  target                = google_compute_target_http_proxy.default.id
  port_range            = "80"
  ip_address            = google_compute_global_address.default.id
  load_balancing_scheme = "EXTERNAL_MANAGED"
}
