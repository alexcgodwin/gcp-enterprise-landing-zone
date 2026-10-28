resource "google_project_service" "iam" {
  project            = var.identity_project_id
  service            = "iam.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "iamcredentials" {
  project            = var.identity_project_id
  service            = "iamcredentials.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "sts" {
  project            = var.identity_project_id
  service            = "sts.googleapis.com"
  disable_on_destroy = false
}

resource "google_iam_workload_identity_pool" "github" {
  project                   = var.identity_project_id
  workload_identity_pool_id = "github-actions-pool"
  display_name              = "GitHub Actions"
  description               = "GitHub Actions OIDC; repository-scoped trust"
  depends_on                = [google_project_service.iam]
}

resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = var.identity_project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-oidc"
  display_name                       = "GitHub OIDC"

  # Numeric identifiers remain fixed even if names change or are taken over.
  # Only the default branch may authenticate; CI does not use this by default.
  attribute_condition = "assertion.repository_owner_id == \"${var.github_owner_id}\" && assertion.repository_id == \"${var.github_repository_id}\" && assertion.ref == \"refs/heads/main\" && assertion.ref_type == \"branch\""
  attribute_mapping = {
    "google.subject"          = "assertion.sub"
    "attribute.repository_id" = "assertion.repository_id"
    "attribute.owner_id"      = "assertion.repository_owner_id"
  }

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account" "terraform_plan" {
  project      = var.identity_project_id
  account_id   = "lz-terraform-plan"
  display_name = "Landing Zone Terraform Plan"
  description  = "Identity is created without resource roles; grant only the reviewed read permissions needed."
  depends_on   = [google_project_service.iam]
}

resource "google_service_account_iam_member" "github" {
  service_account_id = google_service_account.terraform_plan.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository_id/${var.github_repository_id}"

  depends_on = [google_iam_workload_identity_pool_provider.github]
}
