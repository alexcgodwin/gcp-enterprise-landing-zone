variable "project_id" {
  description = "Globally unique Google Cloud project ID."
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Project IDs must be 6-30 characters, start with a letter, and end with a letter or number."
  }
}

variable "display_name" {
  type = string
}

variable "folder_id" {
  description = "Target folder resource name (folders/NNNN)."
  type        = string
}

variable "billing_account" {
  type = string
}

variable "services" {
  type    = set(string)
  default = ["compute.googleapis.com", "logging.googleapis.com"]
}

variable "labels" {
  type    = map(string)
  default = {}
}
