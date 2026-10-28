# Apply this stack with local state first. Migrate it only after the bucket exists.
resource "google_project_service" "storage" {
  project            = var.bootstrap_project_id
  service            = "storage.googleapis.com"
  disable_on_destroy = false
}

resource "google_storage_bucket" "state" {
  project                     = var.bootstrap_project_id
  name                        = var.state_bucket_name
  location                    = var.bucket_location
  storage_class               = "STANDARD"
  force_destroy               = false
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  labels                      = var.labels

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [google_project_service.storage]
}
