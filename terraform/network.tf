# Dedicated VPC so the lab does not depend on the "default" network,
# which many organizations disable.
resource "google_compute_network" "vpc" {
  name                    = "anthos-fleet-vpc"
  auto_create_subnetworks = false
  depends_on              = [google_project_service.apis]
}

locals {
  clusters = {
    "cluster-a" = {
      region      = var.region_a
      zone        = var.zone_a
      subnet_cidr = "10.10.0.0/20"
      pods_cidr   = "10.20.0.0/16"
      svc_cidr    = "10.30.0.0/20"
      master_cidr = "172.16.0.0/28"
    }
    "cluster-b" = {
      region      = var.region_b
      zone        = var.zone_b
      subnet_cidr = "10.11.0.0/20"
      pods_cidr   = "10.21.0.0/16"
      svc_cidr    = "10.31.0.0/20"
      master_cidr = "172.16.0.16/28"
    }
  }
}

resource "google_compute_subnetwork" "subnet" {
  for_each                 = local.clusters
  name                     = "subnet-${each.key}"
  region                   = each.value.region
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = each.value.subnet_cidr
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = each.value.pods_cidr
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = each.value.svc_cidr
  }
}