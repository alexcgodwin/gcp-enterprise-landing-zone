output "state_bucket_name" {
  description = "Remote-state bucket; restrict access to approved Terraform operators."
  value       = google_storage_bucket.state.name
}
