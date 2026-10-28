locals {
  folders = {
    platform      = "Platform"
    security      = "Security"
    production    = "Production"
    nonproduction = "Nonproduction"
  }

  project_definitions = {
    prod_host = { folder = "production", name = "Production Shared VPC Host" }
    dev_host  = { folder = "nonproduction", name = "Nonproduction Shared VPC Host" }
    prod_app  = { folder = "production", name = "Production Application" }
    dev_app   = { folder = "nonproduction", name = "Development Application" }
    audit     = { folder = "security", name = "Central Audit Logging" }
  }

  # Apply to an entire organization ONLY after a policy-impact review.
  baseline_guardrails = toset([
    "compute.skipDefaultNetworkCreation",
    "iam.disableServiceAccountKeyCreation",
    "iam.disableServiceAccountKeyUpload",
  ])
}

resource "google_folder" "root" {
  for_each = local.folders

  display_name        = each.value
  parent              = "organizations/${var.organization_id}"
  deletion_protection = true
}

module "project" {
  for_each = local.project_definitions
  source   = "../../modules/project"

  project_id      = var.project_ids[each.key]
  display_name    = each.value.name
  folder_id       = google_folder.root[each.value.folder].name
  billing_account = var.billing_account
  labels          = merge(var.labels, { environment = each.value.folder })

  services = [
    "compute.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
  ]
}

resource "google_org_policy_policy" "baseline" {
  for_each = var.enable_organization_policies ? local.baseline_guardrails : toset([])

  name   = "organizations/${var.organization_id}/policies/${each.key}"
  parent = "organizations/${var.organization_id}"

  spec {
    rules {
      enforce = "TRUE"
    }
  }
}

resource "google_storage_bucket" "audit_archive" {
  project                     = module.project["audit"].project_id
  name                        = var.audit_bucket_name
  location                    = var.audit_bucket_location
  storage_class               = "STANDARD"
  force_destroy               = false
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  labels                      = merge(var.labels, { data_class = "audit" })

  retention_policy {
    retention_period = 31536000 # 365 days, without irreversible bucket lock.
  }

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [module.project]
}

resource "google_logging_organization_sink" "audit" {
  name             = "org-security-audit-archive"
  org_id           = var.organization_id
  include_children = true
  destination      = "storage.googleapis.com/${google_storage_bucket.audit_archive.name}"

  # Data-access logs may require separate IAM audit configuration to be emitted.
  filter = "log_id(\"cloudaudit.googleapis.com/activity\") OR log_id(\"cloudaudit.googleapis.com/system_event\") OR log_id(\"cloudaudit.googleapis.com/policy\") OR log_id(\"cloudaudit.googleapis.com/data_access\")"
}

resource "google_storage_bucket_iam_member" "sink_writer" {
  bucket = google_storage_bucket.audit_archive.name
  role   = "roles/storage.objectCreator"
  member = google_logging_organization_sink.audit.writer_identity
}
