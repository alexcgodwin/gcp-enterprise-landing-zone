variable "organization_id" {
  description = "Numeric organization ID, provided as a string."
  type        = string
  validation {
    condition     = can(regex("^[0-9]+$", var.organization_id))
    error_message = "Use the numeric organization ID, without the organizations/ prefix."
  }
}

variable "billing_account" {
  description = "Existing billing account ID."
  type        = string
}

variable "project_ids" {
  description = "Unique Google Cloud IDs for the five foundation projects."
  type = object({
    prod_host = string
    dev_host  = string
    prod_app  = string
    dev_app   = string
    audit     = string
  })
  validation {
    condition     = length(distinct(values(var.project_ids))) == 5
    error_message = "All five project IDs must be different."
  }
}

variable "audit_bucket_name" {
  description = "Globally unique bucket name for exported organization audit logs."
  type        = string
}

variable "region" {
  type    = string
  default = "northamerica-northeast1"
}

variable "audit_bucket_location" {
  type    = string
  default = "NORTHAMERICA-NORTHEAST1"
}

variable "enable_organization_policies" {
  description = "False by default to prevent accidental organization-wide policy changes."
  type        = bool
  default     = false
}

variable "labels" {
  description = "Safe labels only; never place identities or secrets in labels."
  type        = map(string)
  default = {
    managed_by = "terraform"
    platform   = "landing-zone"
  }
}
