# Control-plane infrastructure (DESIGN.md §9.3, ADR-010, ADR-022, §15 D86).
# Validated in CI (ci-infra); never applied from CI: an owner applies it with
# -backend-config pointing at the state bucket.
terraform {
  required_version = "= 1.16.5"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "= 5.27.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "= 8.6.0"
    }
  }

  # `terraform init -backend-config=bucket=<state-bucket>`.
  backend "gcs" {
    prefix = "control-plane"
  }
}

provider "cloudflare" {
  # CLOUDFLARE_API_TOKEN from the applying owner's shell.
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}
