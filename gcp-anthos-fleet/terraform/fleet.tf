# Fleet-level features. Per-cluster configuration (Config Sync repo,
# Policy Controller, mesh management) is applied in the next phases.
resource "google_gke_hub_feature" "configmanagement" {
  name       = "configmanagement"
  location   = "global"
  depends_on = [google_project_service.apis]
}

resource "google_gke_hub_feature" "servicemesh" {
  name       = "servicemesh"
  location   = "global"
  depends_on = [google_project_service.apis]
}
