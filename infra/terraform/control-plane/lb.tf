# api.azenfelnas.app: global external Application Load Balancer with a
# Google-managed certificate in front of Cloud Run (§15 D86). Load-balancer
# request logging stays off, so no client address is kept (REQ-PRIV-001).
resource "google_compute_global_address" "api" {
  name       = "control-plane-api"
  depends_on = [google_project_service.apis]
}

resource "google_compute_region_network_endpoint_group" "api" {
  name                  = "control-plane-api"
  region                = var.gcp_region
  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = google_cloud_run_v2_service.api.name
  }
}

resource "google_compute_security_policy" "api" {
  name        = "control-plane-api"
  description = "Per-client throttle; an abuse control only (§15 D86)"

  rule {
    action   = "throttle"
    priority = 1000
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    rate_limit_options {
      conform_action = "allow"
      exceed_action  = "deny(429)"
      enforce_on_key = "IP"
      rate_limit_threshold {
        count        = var.edge_requests_per_minute
        interval_sec = 60
      }
    }
  }

  rule {
    action   = "allow"
    priority = 2147483647
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
  }
}

resource "google_compute_backend_service" "api" {
  name                  = "control-plane-api"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  protocol              = "HTTPS"
  security_policy       = google_compute_security_policy.api.id

  backend {
    group = google_compute_region_network_endpoint_group.api.id
  }

  log_config {
    enable = false
  }
}

resource "google_compute_url_map" "api" {
  name            = "control-plane-api"
  default_service = google_compute_backend_service.api.id
}

resource "google_compute_managed_ssl_certificate" "api" {
  name = "control-plane-api"
  managed {
    domains = [var.api_hostname]
  }
}

resource "google_compute_ssl_policy" "api" {
  name            = "control-plane-api"
  profile         = "MODERN"
  min_tls_version = "TLS_1_2"
}

resource "google_compute_target_https_proxy" "api" {
  name             = "control-plane-api"
  url_map          = google_compute_url_map.api.id
  ssl_certificates = [google_compute_managed_ssl_certificate.api.id]
  ssl_policy       = google_compute_ssl_policy.api.id
}

resource "google_compute_global_forwarding_rule" "api" {
  name                  = "control-plane-api"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_address            = google_compute_global_address.api.id
  port_range            = "443"
  target                = google_compute_target_https_proxy.api.id
}

resource "cloudflare_dns_record" "api" {
  zone_id = var.cloudflare_zone_id
  name    = var.api_hostname
  type    = "A"
  content = google_compute_global_address.api.address
  ttl     = 300
  proxied = false
  comment = "control-plane load balancer (infra/terraform/control-plane)"
}
