locals {
  apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "gkehub.googleapis.com",
    "anthos.googleapis.com",
    "anthosconfigmanagement.googleapis.com",
    "mesh.googleapis.com",
    "multiclusteringress.googleapis.com",
    "multiclusterservicediscovery.googleapis.com",
    "trafficdirector.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
  ]
}

resource "google_project_service" "apis" {
  for_each           = toset(local.apis)
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}
