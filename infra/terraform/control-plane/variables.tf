variable "gcp_project_id" {
  description = "Google Cloud project of the control plane (the distribution module's project)."
  type        = string
}

variable "gcp_region" {
  description = "Region of Cloud Run and Cloud SQL (ADR-022)."
  type        = string
  default     = "europe-west1"
}

variable "cloudflare_zone_id" {
  description = "Zone id of dailymuslim.app."
  type        = string
}

variable "api_hostname" {
  description = "The only control-plane host the app contacts (ADR-017)."
  type        = string
  default     = "api.dailymuslim.app"

  validation {
    condition     = var.api_hostname == "api.dailymuslim.app"
    error_message = "The app's egress allow-list names api.dailymuslim.app only."
  }
}

variable "github_repository" {
  description = "owner/repo whose deploy-control-plane workflow may deploy."
  type        = string
}

variable "workload_identity_pool_name" {
  description = "Full name of the `github` pool created by infra/terraform/distribution (its google_iam_workload_identity_pool.github.name)."
  type        = string
}

variable "image" {
  description = "Initial container image; deploy-control-plane replaces it on every deploy, so later applies ignore it."
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
}

variable "otel_collector_image" {
  description = "OpenTelemetry collector sidecar image with the googlecloud exporters, pinned by digest by the owner (§15 D86)."
  type        = string
}

variable "db_tier" {
  description = "Cloud SQL machine tier; one dedicated vCPU is ample for the 99.5 % SLO (§19.1)."
  type        = string
  default     = "db-custom-1-3840"
}

variable "db_password" {
  description = "Password of the `api` database user; write-only, never stored in state."
  type        = string
  sensitive   = true
  ephemeral   = true
}

variable "db_password_version" {
  description = "Increment to rotate db_password."
  type        = number
  default     = 1
}

variable "android_package" {
  description = "Android application id checked in Play Integrity verdicts."
  type        = string
  default     = "app.dailymuslim"
}

variable "android_cert_sha256" {
  description = "Comma-separated app signing certificate digests (base64url) accepted from Play Integrity; empty accepts any Play-recognised signature."
  type        = string
  default     = ""
}

variable "ios_app_id" {
  description = "<team id>.<bundle id> checked in App Attest; empty leaves iOS writes failing closed."
  type        = string
  default     = ""
}

variable "appattest_root_ca_pem" {
  description = "Apple App Attestation Root CA (PEM) from apple.com/certificateauthority; empty leaves iOS writes failing closed (§15 D86)."
  type        = string
  default     = ""
}

variable "alert_email" {
  description = "Where SLO alerts go (REQ-OPS-003)."
  type        = string
}

variable "edge_requests_per_minute" {
  description = "Cloud Armor per-client throttle at the load balancer; abuse control only, never logged (§15 D86)."
  type        = number
  default     = 120
}
