output "workload_identity_provider" {
  description = "Use with google-github-actions/auth if a separately approved workflow requires it."
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "plan_service_account" {
  description = "Service account without project roles by default."
  value       = google_service_account.terraform_plan.email
}
