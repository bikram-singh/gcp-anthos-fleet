output "get_credentials" {
  value = {
    for k, v in local.clusters :
    k => "gcloud container clusters get-credentials ${k} --zone ${v.zone} --project ${var.project_id}"
  }
}

output "fleet_check" {
  value = "gcloud container fleet memberships list --project ${var.project_id}"
}
