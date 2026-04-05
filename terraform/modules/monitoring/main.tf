# =============================================================================
# Cloud Monitoring Dashboard
# GCP equivalent of: AWS CloudWatch Dashboard
# =============================================================================

resource "google_monitoring_dashboard" "portfolio" {
  project        = var.project_id
  dashboard_json = jsonencode({
    displayName = "${var.project_name} Portfolio Dashboard (${var.environment})"
    gridLayout = {
      columns = 2
      widgets = [
        # Widget 1: Cloud Function — Contact Form Invocations
        {
          title = "Contact Form — Invocations"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type=\"cloud_function\" AND resource.labels.function_name=\"${var.contact_function_name}\" AND metric.type=\"cloudfunctions.googleapis.com/function/execution_count\""
                  aggregation = {
                    alignmentPeriod  = "300s"
                    perSeriesAligner = "ALIGN_RATE"
                  }
                }
              }
            }]
          }
        },
        # Widget 2: Cloud Function — Contact Form Errors
        {
          title = "Contact Form — Errors"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type=\"cloud_function\" AND resource.labels.function_name=\"${var.contact_function_name}\" AND metric.type=\"cloudfunctions.googleapis.com/function/execution_count\" AND metric.labels.status!=\"ok\""
                  aggregation = {
                    alignmentPeriod  = "300s"
                    perSeriesAligner = "ALIGN_RATE"
                  }
                }
              }
            }]
          }
        },
        # Widget 3: Cloud Function — Latency
        {
          title = "Cloud Functions — Execution Latency"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type=\"cloud_function\" AND metric.type=\"cloudfunctions.googleapis.com/function/execution_times\""
                  aggregation = {
                    alignmentPeriod    = "300s"
                    perSeriesAligner   = "ALIGN_PERCENTILE_99"
                  }
                }
              }
            }]
          }
        },
        # Widget 4: Load Balancer — Request Count
        {
          title = "Load Balancer — Request Count"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type=\"https_lb_rule\" AND resource.labels.url_map_name=\"${var.url_map_name}\" AND metric.type=\"loadbalancing.googleapis.com/https/request_count\""
                  aggregation = {
                    alignmentPeriod  = "300s"
                    perSeriesAligner = "ALIGN_RATE"
                  }
                }
              }
            }]
          }
        },
        # Widget 5: Load Balancer — Error Rate
        {
          title = "Load Balancer — 4xx/5xx Errors"
          xyChart = {
            dataSets = [
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "resource.type=\"https_lb_rule\" AND resource.labels.url_map_name=\"${var.url_map_name}\" AND metric.type=\"loadbalancing.googleapis.com/https/request_count\" AND metric.labels.response_code_class=\"400\""
                    aggregation = {
                      alignmentPeriod  = "300s"
                      perSeriesAligner = "ALIGN_RATE"
                    }
                  }
                }
              },
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "resource.type=\"https_lb_rule\" AND resource.labels.url_map_name=\"${var.url_map_name}\" AND metric.type=\"loadbalancing.googleapis.com/https/request_count\" AND metric.labels.response_code_class=\"500\""
                    aggregation = {
                      alignmentPeriod  = "300s"
                      perSeriesAligner = "ALIGN_RATE"
                    }
                  }
                }
              }
            ]
          }
        },
        # Widget 6: Load Balancer — Latency
        {
          title = "Load Balancer — Total Latency"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type=\"https_lb_rule\" AND resource.labels.url_map_name=\"${var.url_map_name}\" AND metric.type=\"loadbalancing.googleapis.com/https/total_latencies\""
                  aggregation = {
                    alignmentPeriod    = "300s"
                    perSeriesAligner   = "ALIGN_PERCENTILE_99"
                  }
                }
              }
            }]
          }
        }
      ]
    }
  })
}