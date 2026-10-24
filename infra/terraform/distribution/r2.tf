# The bucket (§9.1). R2 has no object versioning; rollback is a new
# higher-sequence manifest (ADR-009) and every release-package run keeps the
# published channel as an artifact (§15 D85).
resource "cloudflare_r2_bucket" "dist" {
  account_id = var.cloudflare_account_id
  name       = var.bucket_name
  location   = var.bucket_location

  lifecycle {
    prevent_destroy = true
  }
}

# Packages are content-addressed and immutable (REQ-DIST-003): a lock rule
# per channel refuses their deletion or overwrite. Metadata stays writable.
resource "cloudflare_r2_bucket_lock" "packages" {
  account_id  = var.cloudflare_account_id
  bucket_name = cloudflare_r2_bucket.dist.name

  rules = [
    for channel, days in var.package_lock_days : {
      id      = "${channel}-packages"
      enabled = true
      prefix  = "${channel}/packages/"
      condition = days == 0 ? {
        type            = "Indefinite"
        max_age_seconds = null
        } : {
        type            = "Age"
        max_age_seconds = days * 86400
      }
    }
  ]
}

# Served only through the CDN host; the r2.dev domain stays off.
resource "cloudflare_r2_custom_domain" "cdn" {
  account_id  = var.cloudflare_account_id
  bucket_name = cloudflare_r2_bucket.dist.name
  domain      = var.cdn_hostname
  zone_id     = var.cloudflare_zone_id
  enabled     = true
  min_tls     = "1.2"
}

resource "cloudflare_r2_managed_domain" "r2_dev" {
  account_id  = var.cloudflare_account_id
  bucket_name = cloudflare_r2_bucket.dist.name
  enabled     = false
}
