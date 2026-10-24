# Request and application logs of the control plane live 24 h (§9.3,
# REQ-DATA-002): they are routed to a 1-day bucket and excluded from _Default.
locals {
  control_plane_logs = "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"${google_cloud_run_v2_service.api.name}\""
}

resource "google_logging_project_bucket_config" "requests_24h" {
  project        = var.gcp_project_id
  location       = "global"
  bucket_id      = "control-plane-24h"
  retention_days = 1
  description    = "control-plane request and application logs, kept 24 h (§9.3)"
}

resource "google_logging_project_sink" "requests_24h" {
  name                   = "control-plane-24h"
  destination            = "logging.googleapis.com/${google_logging_project_bucket_config.requests_24h.id}"
  filter                 = local.control_plane_logs
  unique_writer_identity = true
}

resource "google_logging_project_exclusion" "requests_from_default" {
  name        = "control-plane-not-in-default"
  description = "control-plane logs go only to the 24 h bucket"
  filter      = local.control_plane_logs
}

resource "google_monitoring_notification_channel" "email" {
  display_name = "control-plane on-call"
  type         = "email"
  labels = {
    email_address = var.alert_email
  }
}

resource "google_monitoring_uptime_check_config" "readyz" {
  display_name = "api.dailymuslim.app /readyz"
  timeout      = "10s"
  period       = "60s"

  http_check {
    path         = "/readyz"
    port         = 443
    use_ssl      = true
    validate_ssl = true
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.gcp_project_id
      host       = var.api_hostname
    }
  }
}

# §19.1: control plane availability 99.5 % monthly (REQ-OPS-003).
resource "google_monitoring_custom_service" "api" {
  service_id   = "control-plane"
  display_name = "control-plane"
}

resource "google_monitoring_slo" "availability" {
  service         = google_monitoring_custom_service.api.service_id
  slo_id          = "availability-99-5"
  display_name    = "99.5 % of requests succeed (monthly)"
  goal            = 0.995
  calendar_period = "MONTH"

  request_based_sli {
    good_total_ratio {
      bad_service_filter   = "metric.type=\"run.googleapis.com/request_count\" resource.type=\"cloud_run_revision\" resource.label.\"service_name\"=\"control-plane\" metric.label.\"response_code_class\"=\"5xx\""
      total_service_filter = "metric.type=\"run.googleapis.com/request_count\" resource.type=\"cloud_run_revision\" resource.label.\"service_name\"=\"control-plane\""
    }
  }
}

resource "google_monitoring_alert_policy" "slo_burn" {
  display_name = "control-plane SLO burn rate"
  combiner     = "OR"

  conditions {
    display_name = "1 h burn rate above 10x"
    condition_threshold {
      filter          = "select_slo_burn_rate(\"${google_monitoring_slo.availability.id}\", \"3600s\")"
      comparison      = "COMPARISON_GT"
      threshold_value = 10
      duration        = "0s"
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.id]
}

resource "google_monitoring_alert_policy" "uptime" {
  display_name = "control-plane /readyz failing"
  combiner     = "OR"

  conditions {
    display_name = "uptime check failing for 5 min"
    condition_threshold {
      filter          = "metric.type=\"monitoring.googleapis.com/uptime_check/check_passed\" resource.type=\"uptime_url\" metric.label.\"check_id\"=\"${google_monitoring_uptime_check_config.readyz.uptime_check_id}\""
      comparison      = "COMPARISON_GT"
      threshold_value = 1
      duration        = "300s"
      aggregations {
        alignment_period     = "300s"
        per_series_aligner   = "ALIGN_NEXT_OLDER"
        cross_series_reducer = "REDUCE_COUNT_FALSE"
        group_by_fields      = ["resource.label.host"]
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.id]
}
