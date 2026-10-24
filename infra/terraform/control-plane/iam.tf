# Runtime and deploy identities. CI deploys through workload identity
# federation from the `control-plane` GitHub environment (REQ-SEC-030).
resource "google_service_account" "runtime" {
  account_id   = "control-plane-run"
  display_name = "control-plane Cloud Run runtime"
}

resource "google_project_iam_member" "runtime" {
  for_each = toset([
    "roles/cloudsql.client",
    "roles/cloudtrace.agent",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
  ])
  project = var.gcp_project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.runtime.email}"
}

resource "google_secret_manager_secret_iam_member" "runtime" {
  for_each  = { database_url = google_secret_manager_secret.database_url.id, otel_config = google_secret_manager_secret.otel_config.id }
  secret_id = each.value
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.runtime.email}"
}

resource "google_service_account" "deploy" {
  account_id   = "control-plane-deploy"
  display_name = "control-plane deploy (GitHub environment control-plane)"
}

resource "google_service_account_iam_member" "deploy_oidc" {
  service_account_id = google_service_account.deploy.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${var.workload_identity_pool_name}/attribute.environment/control-plane"
}

resource "google_artifact_registry_repository_iam_member" "deploy_push" {
  location   = google_artifact_registry_repository.control_plane.location
  repository = google_artifact_registry_repository.control_plane.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.deploy.email}"
}

resource "google_project_iam_member" "deploy_run" {
  project = var.gcp_project_id
  role    = "roles/run.developer"
  member  = "serviceAccount:${google_service_account.deploy.email}"
}

resource "google_service_account_iam_member" "deploy_acts_as_runtime" {
  service_account_id = google_service_account.runtime.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.deploy.email}"
}

resource "google_service_account" "scheduler" {
  account_id   = "control-plane-scheduler"
  display_name = "Runs the hourly retention purge"
}

resource "google_cloud_run_v2_job_iam_member" "scheduler_runs_purge" {
  name     = google_cloud_run_v2_job.purge.name
  location = var.gcp_region
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.scheduler.email}"
}
