locals {
  sql_socket = "/cloudsql"
  api_env = {
    DM_ENV                   = "production"
    DM_STORE                 = "postgres"
    DM_GCP_PROJECT           = var.gcp_project_id
    DM_TRACE_SAMPLE_RATIO    = "0.1"
    DM_ANDROID_PACKAGE       = var.android_package
    DM_ANDROID_CERT_SHA256   = var.android_cert_sha256
    DM_IOS_APP_ID            = var.ios_app_id
    DM_APPATTEST_ROOT_CA_PEM = var.appattest_root_ca_pem
    # OTLP/HTTP to the collector sidecar (otel-collector.yaml).
    OTEL_EXPORTER_OTLP_ENDPOINT = "http://localhost:4318"
  }
}

# The API: public only through the load balancer (lb.tf), one container
# plus the collector sidecar, scale to zero (§19.1: 99.5 %, not user-critical).
resource "google_cloud_run_v2_service" "api" {
  name                 = "control-plane"
  location             = var.gcp_region
  ingress              = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  invoker_iam_disabled = true
  deletion_protection  = true

  template {
    service_account                  = google_service_account.runtime.email
    timeout                          = "10s"
    max_instance_request_concurrency = 80

    scaling {
      min_instance_count = 0
      max_instance_count = 10
    }

    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [google_sql_database_instance.control_plane.connection_name]
      }
    }

    volumes {
      name = "otel-config"
      secret {
        secret = google_secret_manager_secret.otel_config.secret_id
        items {
          version = "latest"
          path    = "config.yaml"
        }
      }
    }

    containers {
      name       = "api"
      image      = var.image
      args       = ["serve"]
      depends_on = ["otel-collector"]

      ports {
        container_port = 8080
      }

      dynamic "env" {
        for_each = local.api_env
        content {
          name  = env.key
          value = env.value
        }
      }

      env {
        name = "DM_DATABASE_URL"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.database_url.secret_id
            version = "latest"
          }
        }
      }

      volume_mounts {
        name       = "cloudsql"
        mount_path = local.sql_socket
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
        cpu_idle = true
      }

      startup_probe {
        http_get {
          path = "/readyz"
        }
        period_seconds    = 2
        failure_threshold = 15
      }

      liveness_probe {
        http_get {
          path = "/healthz"
        }
        period_seconds = 30
      }
    }

    containers {
      name  = "otel-collector"
      image = var.otel_collector_image
      args  = ["--config=/etc/otelcol/config.yaml"]

      volume_mounts {
        name       = "otel-config"
        mount_path = "/etc/otelcol"
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "256Mi"
        }
        cpu_idle = true
      }

      startup_probe {
        http_get {
          path = "/"
          port = 13133
        }
      }
    }
  }

  lifecycle {
    # deploy-control-plane rolls new images out; Terraform owns everything else.
    ignore_changes = [template[0].containers[0].image, client, client_version]
  }

  depends_on = [google_project_iam_member.runtime, google_secret_manager_secret_iam_member.runtime]
}

# `api migrate` (goose) runs as a job before each rollout (§9.3).
resource "google_cloud_run_v2_job" "migrate" {
  name                = "control-plane-migrate"
  location            = var.gcp_region
  deletion_protection = true

  template {
    task_count = 1
    template {
      service_account = google_service_account.runtime.email
      max_retries     = 0
      timeout         = "300s"

      volumes {
        name = "cloudsql"
        cloud_sql_instance {
          instances = [google_sql_database_instance.control_plane.connection_name]
        }
      }

      containers {
        image = var.image
        args  = ["migrate"]
        env {
          name = "DM_DATABASE_URL"
          value_source {
            secret_key_ref {
              secret  = google_secret_manager_secret.database_url.secret_id
              version = "latest"
            }
          }
        }
        env {
          name  = "DM_ENV"
          value = "production"
        }
        volume_mounts {
          name       = "cloudsql"
          mount_path = local.sql_socket
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [template[0].template[0].containers[0].image, client, client_version]
  }
}

# `api purge` deletes rows past retention every hour (REQ-DATA-002, REQ-PRIV-007).
resource "google_cloud_run_v2_job" "purge" {
  name                = "control-plane-purge"
  location            = var.gcp_region
  deletion_protection = true

  template {
    task_count = 1
    template {
      service_account = google_service_account.runtime.email
      max_retries     = 1
      timeout         = "300s"

      volumes {
        name = "cloudsql"
        cloud_sql_instance {
          instances = [google_sql_database_instance.control_plane.connection_name]
        }
      }

      containers {
        image = var.image
        args  = ["purge"]
        env {
          name = "DM_DATABASE_URL"
          value_source {
            secret_key_ref {
              secret  = google_secret_manager_secret.database_url.secret_id
              version = "latest"
            }
          }
        }
        env {
          name  = "DM_ENV"
          value = "production"
        }
        volume_mounts {
          name       = "cloudsql"
          mount_path = local.sql_socket
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [template[0].template[0].containers[0].image, client, client_version]
  }
}

resource "google_cloud_scheduler_job" "purge" {
  name      = "control-plane-purge-hourly"
  region    = var.gcp_region
  schedule  = "17 * * * *"
  time_zone = "Etc/UTC"

  http_target {
    http_method = "POST"
    uri         = "https://run.googleapis.com/v2/${google_cloud_run_v2_job.purge.id}:run"
    oauth_token {
      service_account_email = google_service_account.scheduler.email
    }
  }

  depends_on = [google_project_service.apis]
}
