output "folders" {
  description = "Created folder resource names."
  value       = { for name, folder in google_folder.root : name => folder.name }
}

output "project_ids" {
  description = "Project IDs for the network and identity stacks."
  value       = { for name, project in module.project : name => project.project_id }
}

output "project_numbers" {
  description = "Project numbers for service agent and federation configuration."
  value       = { for name, project in module.project : name => project.project_number }
}

output "audit_archive_bucket" {
  value = google_storage_bucket.audit_archive.name
}

output "audit_sink_writer" {
  value = google_logging_organization_sink.audit.writer_identity
}
