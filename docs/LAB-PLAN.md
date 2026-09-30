# gcp-anthos-fleet: Full Lab Plan

Hands-on GCP Anthos (GKE Enterprise) fleet lab: two GKE clusters, Config Sync, Policy Controller and Cloud Service Mesh, built with Terraform and GitHub Actions on a GCP free trial account.

**Legend:** 🔧 = hands-on in the lab | 📖 = concept only (covered in the article, not built, because of cost or hardware)

---

## Phase 1: Foundation

🔧 **Hands-on**
- Create the project, link billing, and set budget alerts
- Create a GCS bucket for Terraform remote state
- Set up Workload Identity Federation so GitHub Actions authenticates without service account keys
- Enable the required APIs

**Concepts:** resource hierarchy (org → project), budgets and alerts, keyless CI/CD authentication, remote state and locking

---

## Phase 2: Infrastructure with Terraform

🔧 **Hands-on**
- Custom VPC with VPC-native subnets and secondary ranges (pods and services)
- Two GKE clusters in different regions (Mumbai and Singapore)
- Node pools with Workload Identity enabled
- Cluster registration to the fleet
- CI/CD with GitHub Actions (plan on PR, manual apply and destroy)

**Concepts:** Anthos → GKE Enterprise rebranding, Standard vs Autopilot, VPC-native (alias IP) clusters, release channels, Workload Identity Federation for GKE

---

## Phase 3: Fleet Management

🔧 **Hands-on**
- Inspect fleet memberships in Console and CLI
- Enable fleet-level features (Config Management, Service Mesh)
- Access clusters through Connect Gateway
- Fleet-wide observability and the GKE Enterprise dashboards

**Concepts:** what a fleet is, memberships, fleet-wide "sameness" (namespace, service, identity), Connect Agent and Connect Gateway, fleet-level RBAC

📖 **Concept only:** fleet scopes and teams (team-based namespace management across clusters)

---

## Phase 4: GitOps with Config Sync

🔧 **Hands-on**
- Point both clusters at a Git repo (`config-sync-repo/`)
- Sync a namespace and a default-deny NetworkPolicy
- Push a change to Git and watch it appear on both clusters
- Deliberately change a resource with `kubectl` and watch it get reverted (drift correction)
- Check sync status with `nomos` or the Console

**Concepts:** GitOps, declarative config, RootSync vs RepoSync, unstructured vs hierarchical repo format, drift detection and reconciliation, single source of truth

---

## Phase 5: Policy as Code with Policy Controller

🔧 **Hands-on**
- Enable Policy Controller with the default template library
- Apply constraints, for example: no privileged containers, required labels, allowed image registries
- Try to deploy a violating pod and show it being **denied**
- Switch a constraint to **audit** mode and review the violations report
- Ship the constraints through Config Sync

**Concepts:** OPA Gatekeeper, ConstraintTemplates vs Constraints, admission control, deny vs dryrun/audit enforcement, policy bundles (such as Pod Security Standards, CIS benchmarks), shift-left governance

---

## Phase 6: Cloud Service Mesh (formerly Anthos Service Mesh)

🔧 **Hands-on**
- Enable the managed control plane on both clusters
- Enable automatic sidecar injection for a namespace
- Deploy a sample microservices app
- Verify **mTLS** between services
- Apply an **AuthorizationPolicy** (allow only specific service-to-service calls)
- Traffic management: canary release with a 90/10 traffic split, retries and timeouts
- View the service topology, golden signals (latency, traffic, errors, saturation), and SLOs in Console

**Concepts:** Istio architecture (control plane vs data plane), sidecar proxy (Envoy), managed vs in-cluster control plane, zero-trust networking, PeerAuthentication, VirtualService and DestinationRule, observability without code changes

📖 **Concept only:** Ambient mesh mode, mesh certificate authority options

---

## Phase 7: Multi-Cluster Networking

🔧 **Hands-on**
- Deploy the same app to both clusters
- Enable **Multi-cluster Services (MCS)** so one service is discoverable across clusters
- Optionally, expose it through a **Multi-cluster Gateway** or Multi-cluster Ingress
- Failover test: scale one cluster to zero and confirm traffic moves to the other

**Concepts:** ServiceExport and ServiceImport, `clusterset.local` DNS, config cluster vs member clusters, global load balancing, high availability across regions

> This phase adds load balancer cost, so do it last and clean up right away.

---

## Phase 8: Security and Governance Extras

🔧 **Hands-on (light)**
- Review the GKE security posture dashboard and vulnerability findings
- Least-privilege IAM for the node service account
- Optional: Binary Authorization in dry-run mode

**Concepts:** defense in depth, workload identity vs static keys, supply chain security, Pod Security Standards

---

## Phase 9: Hybrid and Multi-Cloud (Theory)

📖 **Concept only**
- **Google Distributed Cloud** on bare metal, VMware, and air-gapped or edge, and why it needs your own hardware
- **Attached clusters** (registering EKS, AKS, or other CNCF-conformant clusters into a fleet)
- The status of Anthos on AWS/Azure (deprecated in March 2025)
- Pricing model: cloud vs on-prem vCPU rates
- When to use Anthos/GKE Enterprise and when plain GKE is enough

Since real on-prem hardware isn't available in a free trial, `cluster-b` acts as the stand-in for a "remote" environment, and the article should say that clearly.

---

## Phase 10: Cost Review and Cleanup

🔧 **Hands-on**
- `terraform destroy` through GitHub Actions
- Check for leftover load balancers, forwarding rules, static IPs, and disks
- Record the actual spend from the Billing report (this becomes a strong section in the article)

**Concepts:** FinOps basics, cost attribution with labels, why cleanup discipline matters

---

## Article Structure

| Section | Source |
|---|---|
| Why Anthos became GKE Enterprise | Phase 2 concepts |
| Architecture diagram | Phases 2 and 3 |
| Terraform and GitHub Actions setup | Phases 1 and 2 |
| GitOps with Config Sync | Phase 4 |
| Guardrails with Policy Controller | Phase 5 |
| Zero-trust with Service Mesh | Phase 6 |
| Multi-cluster failover | Phase 7 |
| Hybrid options and when to use Anthos | Phase 9 |
| Real cost breakdown and lessons learned | Phase 10 |

---

## Suggested Order and Timing

| Session | Phases | Notes |
|---|---|---|
| Session 1 | 1-3 | About 1-2 hours |
| Session 2 | 4-5 | Light cost |
| Session 3 | 6-7 | Heavier, so destroy afterwards |
| Anytime | 8-9 | Reading and screenshots |
