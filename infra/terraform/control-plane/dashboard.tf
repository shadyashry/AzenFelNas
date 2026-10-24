# S28 ops dashboard and the D87 alerts that were still open (DESIGN.md §19.1–§19.2, REQ-OPS-003, §15 D88).
# Built only from the D86 access log (method, route pattern, status; no IP, no coordinates) and platform metrics.

locals {
  access_log = "resource.type=\"cloud_run_revision\" resource.labels.service_name=\"control-plane\" jsonPayload.message=\"request\""
}

# Attested writes: every POST route needs attestation (REQ-API-004).
resource "google_logging_metric" "write_requests" {
  name   = "control_plane_write_requests"
  filter = "${local.access_log} jsonPayload.method=\"POST\""
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}

# A 401 is returned only for a missing or invalid attestation (problem types attestation-required/-invalid).
resource "google_logging_metric" "attestation_failures" {
  name   = "control_plane_attestation_failures"
  filter = "${local.access_log} jsonPayload.method=\"POST\" jsonPayload.status=401"
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "attestation_failure_rate" {
  display_name = "control-plane attestation failure rate above 20 %"
  combiner     = "OR"

  conditions {
    display_name = "401 share of POSTs over 1 h above 0.2 (at least 20 writes)"
    condition_prometheus_query_language {
      query               = <<-PROMQL
        (sum(increase(logging_googleapis_com:user_control_plane_attestation_failures[1h]))
          / sum(increase(logging_googleapis_com:user_control_plane_write_requests[1h])) > 0.2)
        and on() (sum(increase(logging_googleapis_com:user_control_plane_write_requests[1h])) >= 20)
      PROMQL
      duration            = "0s"
      evaluation_interval = "300s"
    }
  }

  documentation {
    content   = "Runbooks: docs/runbooks/key-compromise.md (attestation keys), docs/runbooks/control-plane-restore.md."
    mime_type = "text/markdown"
  }

  notification_channels = [google_monitoring_notification_channel.email.id]
}

resource "google_monitoring_alert_policy" "postgres_disk" {
  display_name = "control-plane Postgres disk above 80 %"
  combiner     = "OR"

  conditions {
    display_name = "disk utilization above 0.8 for 10 min"
    condition_threshold {
      filter          = "metric.type=\"cloudsql.googleapis.com/database/disk/utilization\" resource.type=\"cloudsql_database\" resource.label.\"database_id\"=\"${var.gcp_project_id}:${google_sql_database_instance.control_plane.name}\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0.8
      duration        = "600s"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MAX"
      }
    }
  }

  documentation {
    content   = "Runbook: docs/runbooks/control-plane-restore.md. Retention jobs (D86) should keep the disk flat; growth means a purge job is failing."
    mime_type = "text/markdown"
  }

  notification_channels = [google_monitoring_notification_channel.email.id]
}

resource "google_monitoring_dashboard" "ops" {
  dashboard_json = jsonencode({
    displayName = "Daily Muslim ops (V1)"
    mosaicLayout = {
      columns = 12
      tiles = [
        {
          xPos = 0, yPos = 0, width = 6, height = 4
          widget = {
            title = "Requests by response class"
            xyChart = {
              dataSets = [{
                plotType = "STACKED_AREA"
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"run.googleapis.com/request_count\" resource.type=\"cloud_run_revision\" resource.label.\"service_name\"=\"control-plane\""
                    aggregation = {
                      alignmentPeriod    = "300s"
                      perSeriesAligner   = "ALIGN_RATE"
                      crossSeriesReducer = "REDUCE_SUM"
                      groupByFields      = ["metric.label.\"response_code_class\""]
                    }
                  }
                }
              }]
            }
          }
        },
        {
          xPos = 6, yPos = 0, width = 6, height = 4
          widget = {
            title = "Request latency p95"
            xyChart = {
              dataSets = [{
                plotType = "LINE"
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"run.googleapis.com/request_latencies\" resource.type=\"cloud_run_revision\" resource.label.\"service_name\"=\"control-plane\""
                    aggregation = {
                      alignmentPeriod    = "300s"
                      perSeriesAligner   = "ALIGN_DELTA"
                      crossSeriesReducer = "REDUCE_PERCENTILE_95"
                    }
                  }
                }
              }]
            }
          }
        },
        {
          xPos = 0, yPos = 4, width = 4, height = 4
          widget = {
            title = "Availability SLO (99.5 %) error budget"
            scorecard = {
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "select_slo_budget_fraction(\"${google_monitoring_slo.availability.id}\")"
                }
              }
            }
          }
        },
        {
          xPos = 4, yPos = 4, width = 4, height = 4
          widget = {
            title = "Attestation failures / writes (1 h)"
            xyChart = {
              dataSets = [{
                plotType = "LINE"
                timeSeriesQuery = {
                  prometheusQuery = "sum(increase(logging_googleapis_com:user_control_plane_attestation_failures[1h])) / sum(increase(logging_googleapis_com:user_control_plane_write_requests[1h]))"
                }
              }]
              thresholds = [{ value = 0.2 }]
            }
          }
        },
        {
          xPos = 8, yPos = 4, width = 4, height = 4
          widget = {
            title = "Postgres disk utilization"
            xyChart = {
              dataSets = [{
                plotType = "LINE"
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"cloudsql.googleapis.com/database/disk/utilization\" resource.type=\"cloudsql_database\""
                    aggregation = {
                      alignmentPeriod  = "300s"
                      perSeriesAligner = "ALIGN_MAX"
                    }
                  }
                }
              }]
              thresholds = [{ value = 0.8 }]
            }
          }
        },
        {
          xPos = 0, yPos = 8, width = 6, height = 4
          widget = {
            title = "Attested writes (POST) per hour"
            xyChart = {
              dataSets = [{
                plotType = "STACKED_BAR"
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"logging.googleapis.com/user/${google_logging_metric.write_requests.name}\" resource.type=\"cloud_run_revision\""
                    aggregation = {
                      alignmentPeriod    = "3600s"
                      perSeriesAligner   = "ALIGN_DELTA"
                      crossSeriesReducer = "REDUCE_SUM"
                    }
                  }
                }
              }]
            }
          }
        },
        {
          xPos = 6, yPos = 8, width = 6, height = 4
          widget = {
            title = "/readyz uptime check"
            xyChart = {
              dataSets = [{
                plotType = "LINE"
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"monitoring.googleapis.com/uptime_check/check_passed\" resource.type=\"uptime_url\" metric.label.\"check_id\"=\"${google_monitoring_uptime_check_config.readyz.uptime_check_id}\""
                    aggregation = {
                      alignmentPeriod    = "300s"
                      perSeriesAligner   = "ALIGN_FRACTION_TRUE"
                      crossSeriesReducer = "REDUCE_MEAN"
                    }
                  }
                }
              }]
            }
          }
        },
        {
          xPos = 0, yPos = 12, width = 12, height = 2
          widget = {
            title = "Distribution and calendar alerts"
            text = {
              format  = "MARKDOWN"
              content = "CDN availability, timestamp freshness and publish jobs are watched by the GitHub release workflows and the IANA/canary watch (docs/runbooks/README.md). Runbooks: docs/runbooks/."
            }
          }
        },
      ]
    }
  })
}
