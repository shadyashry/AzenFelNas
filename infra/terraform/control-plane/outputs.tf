output "api_address" {
  description = "Global IP of api.dailymuslim.app."
  value       = google_compute_global_address.api.address
}

output "sql_connection_name" {
  description = "Use in DM_DATABASE_URL: host=/cloudsql/<this> user=api dbname=controlplane."
  value       = google_sql_database_instance.control_plane.connection_name
}

output "image_repository" {
  description = "Artifact Registry path for deploy-control-plane."
  value       = "${var.gcp_region}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.control_plane.repository_id}/api"
}

output "deploy_service_account" {
  description = "Service account the deploy workflow impersonates (GitHub variable GCP_DEPLOY_SERVICE_ACCOUNT)."
  value       = google_service_account.deploy.email
}

output "logging_sink_writer" {
  description = "Writer identity of the 24 h log sink."
  value       = google_logging_project_sink.requests_24h.writer_identity
}
