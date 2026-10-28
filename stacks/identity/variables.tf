variable "identity_project_id" {
  description = "EXISTING GCP project to hold Workload Identity Federation (for example the bootstrap project)."
  type        = string
}

variable "github_owner_id" {
  description = "Immutable numeric GitHub account/organization ID, NOT the login."
  type        = string
  validation {
    condition     = can(regex("^[0-9]+$", var.github_owner_id))
    error_message = "github_owner_id must contain only digits."
  }
}

variable "github_repository_id" {
  description = "Immutable numeric GitHub repository ID, NOT the repository name."
  type        = string
  validation {
    condition     = can(regex("^[0-9]+$", var.github_repository_id))
    error_message = "github_repository_id must contain only digits."
  }
}

variable "github_repository" {
  description = "Readable owner/name, used for display and audit only."
  type        = string
}
