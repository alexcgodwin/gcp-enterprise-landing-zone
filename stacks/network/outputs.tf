output "network_self_links" {
  value = { for env, network in google_compute_network.private : env => network.self_link }
}

output "subnet_self_links" {
  value = { for env, subnet in google_compute_subnetwork.private : env => subnet.self_link }
}

output "shared_vpc_hosts" {
  value = { for env, host in google_compute_shared_vpc_host_project.host : env => host.project }
}

output "nat_names" {
  value = { for env, nat in google_compute_router_nat.egress : env => nat.name }
}
