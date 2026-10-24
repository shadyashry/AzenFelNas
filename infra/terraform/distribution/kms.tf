# The targets role of beta and production lives in Cloud KMS (§9.1); only
# the matching GitHub environment of this repository may sign, through
# workload identity federation (no key file, REQ-SEC-030). The environments'
# required reviewers are the dual control (owner setting, §15 D85).
resource "google_project_service" "apis" {
  for_each = toset([
    "cloudkms.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
  ])
  service            = each.value
  disable_on_destroy = false
}

resource "google_kms_key_ring" "distribution" {
  name     = "dm-distribution"
  location = var.gcp_region

  depends_on = [google_project_service.apis]
}

resource "google_kms_crypto_key" "targets" {
  for_each = var.kms_channels
  name     = "${each.key}-targets-1"
  key_ring = google_kms_key_ring.distribution.id
  purpose  = "ASYMMETRIC_SIGN"

  version_template {
    algorithm        = "EC_SIGN_ED25519"
    protection_level = var.kms_protection_level
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = "github"
  display_name              = "GitHub Actions"

  depends_on = [google_project_service.apis]
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions"
  display_name                       = "GitHub Actions OIDC"
  attribute_mapping = {
    "google.subject"         = "assertion.sub"
    "attribute.repository"   = "assertion.repository"
    "attribute.environment"  = "assertion.environment"
    "attribute.workflow_ref" = "assertion.job_workflow_ref"
  }
  attribute_condition = "assertion.repository == \"${var.github_repository}\""

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account" "release" {
  for_each     = var.kms_channels
  account_id   = "dm-release-${each.key}"
  display_name = "Package release signer (${each.key})"
}

# A job may impersonate a channel's signer only from that GitHub environment.
resource "google_service_account_iam_member" "release_oidc" {
  for_each           = var.kms_channels
  service_account_id = google_service_account.release[each.key].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.environment/${each.key}"
}

resource "google_kms_crypto_key_iam_member" "release_signs" {
  for_each      = var.kms_channels
  crypto_key_id = google_kms_crypto_key.targets[each.key].id
  role          = "roles/cloudkms.signerVerifier"
  member        = "serviceAccount:${google_service_account.release[each.key].email}"
}
