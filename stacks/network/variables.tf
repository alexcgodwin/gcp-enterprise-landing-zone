variable "default_region" {
  type    = string
  default = "northamerica-northeast1"
}

variable "environments" {
  description = "Isolated VPC host/service project per environment. Non-overlapping CIDRs required."
  type = map(object({
    host_project_id    = string
    service_project_id = string
    region             = string
    subnet_cidr        = string
  }))
  validation {
    condition     = length(var.environments) > 0 && alltrue([for k, v in var.environments : k == "prod" || k == "dev"])
    error_message = "Use only prod and/or dev environment keys."
  }
  validation {
    condition     = length(distinct([for v in values(var.environments) : v.host_project_id])) == length(var.environments)
    error_message = "Each environment needs its own VPC host project."
  }
  validation {
    condition     = length(distinct([for v in values(var.environments) : v.subnet_cidr])) == length(var.environments)
    error_message = "Do not reuse an identical subnet range in multiple environments. Check for partial CIDR overlaps separately."
  }
}

variable "subnet_users" {
  description = "Optional IAM principals explicitly permitted on each environment's subnet. Format: user:name@example.com, group:team@example.com or serviceAccount:id@project.iam.gserviceaccount.com."
  type        = map(set(string))
  default     = {}
  validation {
    condition     = alltrue(flatten([for principals in values(var.subnet_users) : [for principal in principals : can(regex("^(user|group|serviceAccount):[^ ]+$", principal))]]))
    error_message = "Use full IAM principals (user:, group:, serviceAccount:) and never allUsers or allAuthenticatedUsers."
  }
}
