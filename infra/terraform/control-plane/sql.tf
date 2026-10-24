# Cloud SQL for PostgreSQL 16 (ADR-022). Reached only through the Cloud SQL
# connector socket mounted into Cloud Run; no authorised networks.
resource "google_sql_database_instance" "control_plane" {
  name                = "control-plane"
  database_version    = "POSTGRES_16"
  region              = var.gcp_region
  deletion_protection = true

  settings {
    tier              = var.db_tier
    edition           = "ENTERPRISE"
    availability_type = "ZONAL"
    disk_autoresize   = true
    disk_size         = 10

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
      start_time                     = "02:00"
      transaction_log_retention_days = 7
      backup_retention_settings {
        retained_backups = 14
      }
    }

    ip_configuration {
      ipv4_enabled = true
      ssl_mode     = "ENCRYPTED_ONLY"
    }

    maintenance_window {
      day  = 7
      hour = 3
    }

    insights_config {
      query_insights_enabled  = true
      record_application_tags = false
      record_client_address   = false
    }
  }

  depends_on = [google_project_service.apis]
}

resource "google_sql_database" "control_plane" {
  name     = "controlplane"
  instance = google_sql_database_instance.control_plane.name
}

resource "google_sql_user" "api" {
  name                = "api"
  instance            = google_sql_database_instance.control_plane.name
  password_wo         = var.db_password
  password_wo_version = var.db_password_version
}

# DM_DATABASE_URL; the owner adds the version (host=/cloudsql/<connection name>, §15 D86).
resource "google_secret_manager_secret" "database_url" {
  secret_id = "control-plane-database-url"
  replication {
    user_managed {
      replicas {
        location = var.gcp_region
      }
    }
  }
  depends_on = [google_project_service.apis]
}

resource "google_secret_manager_secret" "otel_config" {
  secret_id = "control-plane-otel-collector-config"
  replication {
    user_managed {
      replicas {
        location = var.gcp_region
      }
    }
  }
  depends_on = [google_project_service.apis]
}

resource "google_secret_manager_secret_version" "otel_config" {
  secret      = google_secret_manager_secret.otel_config.id
  secret_data = file("${path.module}/otel-collector.yaml")
}
