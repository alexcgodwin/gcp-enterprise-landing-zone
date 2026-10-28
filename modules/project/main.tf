resource "google_project" "this" {
  name            = var.display_name
  project_id      = var.project_id
  folder_id       = var.folder_id
  billing_account = var.billing_account
  labels          = var.labels

  # Projects must not be destroyed through routine IaC cleanups.
  deletion_policy = "PREVENT"
}

resource "google_project_service" "enabled" {
  for_each = var.services

  project            = google_project.this.project_id
  service            = each.value
  disable_on_destroy = false
}
