locals {
  connection = google_cloud_run_v2_service.cloudrun.uri
}

#
# Orchestration
#

output "context" {
  description = "The input context, a map, which is used for orchestration."
  value       = var.context
}

output "connection" {
  description = "The connection, the main URI in which this Service is serving traffic."
  value       = local.connection
}
