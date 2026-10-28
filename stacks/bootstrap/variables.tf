variable "bootstrap_project_id" {
  description = "Existing GCP bootstrap project, linked to billing."
  type        = string
}

variable "state_bucket_name" {
  description = "Globally unique GCS bucket name."
  type        = string
}

variable "region" {
  type    = string
  default = "northamerica-northeast1"
}

variable "bucket_location" {
  type    = string
  default = "NORTHAMERICA-NORTHEAST1"
}

variable "labels" {
  type = map(string)
  default = {
    managed_by = "terraform"
    layer      = "bootstrap"
  }
}
