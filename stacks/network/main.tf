locals {
  subnet_grants = {
    for pair in flatten([
      for env, principals in var.subnet_users : [
        for principal in principals : {
          key       = "${env}-${sha1(principal)}"
          env       = env
          principal = principal
        }
      ]
    ]) : pair.key => pair
  }
}

resource "google_compute_shared_vpc_host_project" "host" {
  for_each = var.environments
  project  = each.value.host_project_id
}

resource "google_compute_network" "private" {
  for_each                        = var.environments
  project                         = each.value.host_project_id
  name                            = "lz-${each.key}-vpc"
  auto_create_subnetworks         = false
  routing_mode                    = "REGIONAL"
  delete_default_routes_on_create = false
  depends_on                      = [google_compute_shared_vpc_host_project.host]
}

resource "google_compute_subnetwork" "private" {
  for_each = var.environments

  project                  = each.value.host_project_id
  name                     = "lz-${each.key}-private"
  ip_cidr_range            = each.value.subnet_cidr
  region                   = each.value.region
  network                  = google_compute_network.private[each.key].id
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_router" "private" {
  for_each = var.environments
  project  = each.value.host_project_id
  name     = "lz-${each.key}-router"
  region   = each.value.region
  network  = google_compute_network.private[each.key].name
}

resource "google_compute_router_nat" "egress" {
  for_each                           = var.environments
  project                            = each.value.host_project_id
  name                               = "lz-${each.key}-nat"
  router                             = google_compute_router.private[each.key].name
  region                             = each.value.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.private[each.key].id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_shared_vpc_service_project" "application" {
  for_each = var.environments

  host_project    = google_compute_shared_vpc_host_project.host[each.key].project
  service_project = each.value.service_project_id
}

# Not everyone who has permissions in a service project should be able to use
# a subnet. Explicitly list approved IAM principals. Nothing is granted by default.
resource "google_compute_subnetwork_iam_member" "network_user" {
  for_each   = local.subnet_grants
  project    = var.environments[each.value.env].host_project_id
  region     = var.environments[each.value.env].region
  subnetwork = google_compute_subnetwork.private[each.value.env].name
  role       = "roles/compute.networkUser"
  member     = each.value.principal

  depends_on = [google_compute_shared_vpc_service_project.application]
}
