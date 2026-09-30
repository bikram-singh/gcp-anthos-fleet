resource "google_container_cluster" "cluster" {
  for_each = local.clusters

  name                     = each.key
  location                 = each.value.zone
  network                  = google_compute_network.vpc.id
  subnetwork               = google_compute_subnetwork.subnet[each.key].id
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false

  release_channel {
    channel = "REGULAR"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Registers the cluster to the project's fleet
  fleet {
    project = var.project_id
  }

  depends_on = [google_project_service.apis]
}

resource "google_container_node_pool" "pool" {
  for_each = local.clusters

  name       = "primary"
  cluster    = google_container_cluster.cluster[each.key].name
  location   = each.value.zone
  node_count = var.node_count

  node_config {
    machine_type = var.machine_type
    disk_size_gb = 50
    disk_type    = "pd-standard"
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
}
