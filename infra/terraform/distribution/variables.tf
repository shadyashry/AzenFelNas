variable "cloudflare_account_id" {
  description = "Cloudflare account that owns the R2 bucket."
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Zone id of dailymuslim.app."
  type        = string
}

variable "cdn_hostname" {
  description = "The only distribution host the app contacts (ADR-017, REQ-PRIV-006)."
  type        = string
  default     = "cdn.dailymuslim.app"

  validation {
    condition     = var.cdn_hostname == "cdn.dailymuslim.app"
    error_message = "The app's egress allow-list names cdn.dailymuslim.app only."
  }
}

variable "bucket_name" {
  description = "R2 bucket holding every channel in the §9.1 layout."
  type        = string
  default     = "dm-dist"
}

variable "bucket_location" {
  description = "R2 location hint; Western Europe, next to the control plane region (§15 D85)."
  type        = string
  default     = "WEUR"
}

variable "gcp_project_id" {
  description = "Google Cloud project of the release keys."
  type        = string
}

variable "gcp_region" {
  description = "Region of the key ring (ADR-022)."
  type        = string
  default     = "europe-west1"
}

variable "kms_protection_level" {
  description = "Protection level of the targets keys; HSM unless Cloud KMS refuses EC_SIGN_ED25519 there (§15 D85, open)."
  type        = string
  default     = "HSM"

  validation {
    condition     = contains(["HSM", "SOFTWARE"], var.kms_protection_level)
    error_message = "HSM or SOFTWARE."
  }
}

variable "github_repository" {
  description = "owner/name of the repository whose release environments may sign (OIDC, REQ-SEC-030)."
  type        = string
}

variable "kms_channels" {
  description = "Channels whose targets role is signed in KMS; dev and lab use the dev keys (§15 D62)."
  type        = set(string)
  default     = ["beta", "production"]
}

variable "package_lock_days" {
  description = "R2 bucket-lock retention of packages per channel, in days; 0 = indefinite (§15 D85)."
  type        = map(number)
  default = {
    dev        = 365
    lab        = 365
    beta       = 0
    production = 0
  }
}
