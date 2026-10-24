output "bucket" {
  description = "gsctl -bucket value: s3://<bucket>."
  value       = "s3://${cloudflare_r2_bucket.dist.name}"
}

output "s3_endpoint" {
  description = "DM_S3_ENDPOINT for gsctl (R2's S3 API host)."
  value       = "${var.cloudflare_account_id}.r2.cloudflarestorage.com"
}

output "kms_targets_key_versions" {
  description = "DM_KMS_TARGETS_KEY_1 per KMS channel (first version)."
  value       = { for c, k in google_kms_crypto_key.targets : c => "${k.id}/cryptoKeyVersions/1" }
}

output "workload_identity_provider" {
  description = "google-github-actions/auth workload_identity_provider."
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "release_service_accounts" {
  description = "google-github-actions/auth service_account per KMS channel."
  value       = { for c, sa in google_service_account.release : c => sa.email }
}
