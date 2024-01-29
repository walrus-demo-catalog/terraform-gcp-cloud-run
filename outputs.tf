locals {
endpoints = {
    url = google_cloud_run_v2_service.cloudrun.uri
  }
}

#
# Orchestration
#

output "context" {
  description = "The input context, a map, which is used for orchestration."
  value       = var.context
}

output "endpoints" {
  description = "The endpoints, a string map, the key is the name, and the value is the URL."
  value       = local.endpoints
}