# Private nodes have no external IPs (the org policy
# constraints/compute.vmExternalIpAccess blocks them), so Cloud NAT gives
# them outbound access to pull images and reach GitHub (Config Sync).
resource "google_compute_router" "router" {
  for_each = local.clusters
  name     = "router-${each.key}"
  region   = each.value.region
  network  = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  for_each                           = local.clusters
  name                               = "nat-${each.key}"
  router                             = google_compute_router.router[each.key].name
  region                             = each.value.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}