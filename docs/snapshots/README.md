# Snapshots

Console and terminal captures from the lab, grouped by section. Section numbers match docs/LAB-PLAN.md.

> These are real captures from one trial project. The project was shut down after the lab, so the resources shown no longer exist.

## 1. Foundation

**Billing → Budgets & alerts**

![Billing → Budgets & alerts](01-foundation/01-billing-budgets-and-alerts.png)

**Cloud Storage → Buckets (Terraform state bucket)**

![Cloud Storage → Buckets (Terraform state bucket)](01-foundation/02-cloud-storage-terraform-state-bucket.png)

**IAM & Admin → Service Accounts (tf-github-actions)**

![IAM & Admin → Service Accounts (tf-github-actions)](01-foundation/03-iam-service-accounts.png)

Not captured:

- IAM & Admin → Workload Identity Federation (the pool and provider page)

## 2. Infrastructure

**VPC network → VPC networks**

![VPC network → VPC networks](02-infrastructure/01-vpc-networks.png)

**Network services → Cloud NAT**

![Network services → Cloud NAT](02-infrastructure/02-cloud-nat.png)

**Hybrid Connectivity → Cloud Routers**

![Hybrid Connectivity → Cloud Routers](02-infrastructure/03-cloud-routers.png)

**Kubernetes Engine → Clusters**

![Kubernetes Engine → Clusters](02-infrastructure/04-gke-clusters.png)

**Kubernetes Engine → cluster-a → Nodes**

![Kubernetes Engine → cluster-a → Nodes](02-infrastructure/05-gke-cluster-a-nodes.png)

**Compute Engine → VM instances (no external IPs)**

![Compute Engine → VM instances (no external IPs)](02-infrastructure/06-compute-engine-vm-instances.png)

## 3. Fleet

**Kubernetes Engine → Fleet Dashboard**

![Kubernetes Engine → Fleet Dashboard](03-fleet/01-fleet-dashboard.png)

**Platform Management → Feature manager**

![Platform Management → Feature manager](03-fleet/02-feature-manager.png)

**Terminal: fleet memberships, fleet features, Connect Gateway**

![Terminal: fleet memberships, fleet features, Connect Gateway](03-fleet/03-fleet-memberships-features-cli.png)

## 4. Config Sync

_The order follows the install flow, reconstructed from the screens. The screenshots carry no timestamps._

**Install Config Sync on individual clusters**

![Install Config Sync on individual clusters](04-config-sync/01-install-config-sync-dialog.png)

**Config delivery → Settings, install pending**

![Config delivery → Settings, install pending](04-config-sync/02-settings-clusters-pending.png)

**Config delivery → Settings, both clusters enabled**

![Config delivery → Settings, both clusters enabled](04-config-sync/03-settings-clusters-enabled.png)

**Config delivery → Dashboard, before the first package**

![Config delivery → Dashboard, before the first package](04-config-sync/04-dashboard-before-first-package.png)

**Feature manager → Config Sync overview**

![Feature manager → Config Sync overview](04-config-sync/05-feature-manager-config-sync.png)

**Feature manager → Sync to fleet settings**

![Feature manager → Sync to fleet settings](04-config-sync/06-sync-to-fleet-settings-confirm.png)

**Feature manager → clusters in sync with fleet**

![Feature manager → clusters in sync with fleet](04-config-sync/07-feature-manager-clusters-in-sync.png)

**Terminal: Config Sync pods and the RootSync CRD**

![Terminal: Config Sync pods and the RootSync CRD](04-config-sync/08-config-sync-pods-and-rootsync-crd-cli.png)

**Terminal: RootSync applied to both clusters**

![Terminal: RootSync applied to both clusters](04-config-sync/09-rootsync-applied-cli.png)

**Config delivery → Dashboard with root-sync**

![Config delivery → Dashboard with root-sync](04-config-sync/10-config-delivery-dashboard-root-sync.png)

**Config delivery → Packages, root-sync synced on both clusters**

![Config delivery → Packages, root-sync synced on both clusters](04-config-sync/11-config-delivery-packages-root-sync.png)

**Config delivery → Settings, in sync with fleet**

![Config delivery → Settings, in sync with fleet](04-config-sync/12-config-delivery-settings-in-sync.png)

## 5. Policy Controller

**Platform Management → Policy**

![Platform Management → Policy](05-policy-controller/01-policy-dashboard.png)

Not captured:

- Constraint violations view and a webhook denial screenshot

## 6. Service Mesh

**Service Mesh: services, traffic and topology**

![Service Mesh: services, traffic and topology](06-service-mesh/01-service-mesh-topology.png)

**Workloads: both clusters**

![Workloads: both clusters](06-service-mesh/02-workloads-all-clusters.png)

**Workloads: cluster-a**

![Workloads: cluster-a](06-service-mesh/03-workloads-cluster-a.png)

**Workloads: cluster-b**

![Workloads: cluster-b](06-service-mesh/04-workloads-cluster-b.png)

**Service Mesh: webapp service details**

![Service Mesh: webapp service details](06-service-mesh/05-service-mesh-webapp-details.png)

## 7. Multi-cluster Services and Gateway

**Gateways, Services & Ingress → Services (cluster-a)**

![Gateways, Services & Ingress → Services (cluster-a)](07-multi-cluster-services/01-services-cluster-a.png)

**Gateways, Services & Ingress → Services (cluster-b)**

![Gateways, Services & Ingress → Services (cluster-b)](07-multi-cluster-services/02-services-cluster-b.png)

**VPC network → Firewall (MCS rules highlighted)**

![VPC network → Firewall (MCS rules highlighted)](07-multi-cluster-services/03-vpc-firewall-rules.png)

**Network services → Load balancing → Load balancers**

![Network services → Load balancing → Load balancers](07-multi-cluster-services/04-load-balancing-load-balancers.png)

**Load balancing → Backends**

![Load balancing → Backends](07-multi-cluster-services/05-load-balancing-backends.png)

**Load balancing → Frontends**

![Load balancing → Frontends](07-multi-cluster-services/06-load-balancing-frontends.png)

**Load balancing → Service LB policies**

![Load balancing → Service LB policies](07-multi-cluster-services/07-load-balancing-service-lb-policies.png)

**Gateways, Services & Ingress → Gateway details**

![Gateways, Services & Ingress → Gateway details](07-multi-cluster-services/08-gateway-details.png)

**Gateway details → Resource view**

![Gateway details → Resource view](07-multi-cluster-services/09-gateway-resource-view.png)

**Gateways, Services & Ingress → Http Routes tab**

![Gateways, Services & Ingress → Http Routes tab](07-multi-cluster-services/10-gateway-http-routes.png)

Not captured:

- Feature manager card for Multi-cluster Services (the Console had no such card)
- Gateways tab list view (only the Gateway details pages were captured)
- Network services → Cloud DNS (no zones existed)

## Not captured at all

- RepoSync, Workload Identity, custom ConstraintTemplate, fleet scopes and Binary Authorization have terminal evidence in docs/LAB-PLAN.md but no screenshots here.
