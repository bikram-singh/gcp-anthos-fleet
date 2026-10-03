# gcp-anthos-fleet: Lab Plan and Progress

Hands-on GCP Anthos (GKE Enterprise) fleet lab: two private GKE clusters in two regions, Config Sync, Policy Controller, Cloud Service Mesh, Multi-cluster Services and a multi-cluster Gateway, built with Terraform and GitHub Actions on a GCP free trial account.

**Legend:** ✅ done | ⚠️ done with caveats | ⬜ not done | 🔧 hands-on | 📖 concept only

> Status below reflects what was actually run in this lab. Numbers are single runs unless stated, and "not verified" means it was not checked, not that it is wrong.

---

## Status at a glance

| Phase | Topic | Status |
|---|---|---|
| 1 | Foundation | ✅ |
| 2 | Infrastructure with Terraform | ⚠️ needed private nodes and Cloud NAT (org policy) |
| 3 | Fleet management | ✅ |
| 4 | GitOps with Config Sync | ⚠️ RootSync applied with `kubectl` (see notes) |
| 5 | Policy as code with Policy Controller | ✅ |
| 6 | Cloud Service Mesh | ⚠️ ran on cluster-b only, SLO view not tried |
| 7 | Multi-cluster networking | ✅ MCS, Gateway, failover and weighted split measured |
| 8 | Security and governance extras | ⚠️ node service account not replaced |
| 9 | Hybrid and multi-cloud | 📖 theory, to be written in the article |
| 10 | Cost review and cleanup | ⬜ not started |
| Extras | Gateway weighted split, RepoSync, Workload Identity, custom ConstraintTemplate, fleet scopes, Binary Authorization dry-run | ✅ all six done |

---

## Phase 1: Foundation ✅

🔧 **Done**
- Project `gcp-anthos-fleet`, billing linked, ₹3,000 budget with alerts at 50%, 90% and 100%
- GCS bucket for Terraform state (`gcp-anthos-fleet-tfstate`), versioning on
- Service account `tf-github-actions` and Workload Identity Federation (`github-pool`) so GitHub Actions authenticates without keys
- Three GitHub secrets set with the `gh` CLI: `WIF_PROVIDER`, `WIF_SERVICE_ACCOUNT`, `TF_STATE_BUCKET`

**Concepts:** resource hierarchy, budgets and alerts (alerts only email, they do not stop spending), keyless CI/CD authentication, remote state and locking

---

## Phase 2: Infrastructure with Terraform ⚠️

🔧 **Done**
- Custom VPC `anthos-fleet-vpc` with VPC-native subnets and secondary ranges for pods and services
- Two **private** GKE clusters: `cluster-a` (asia-south1-a, Mumbai) and `cluster-b` (asia-southeast1-a, Singapore), 2 × e2-standard-4 nodes each
- Cloud Router and Cloud NAT in both regions
- Workload Identity enabled, clusters registered to the fleet, fleet features enabled
- GitHub Actions workflow: plan on request, manual apply and destroy

**What went differently**
- The first apply failed: the organization enforces `constraints/compute.vmExternalIpAccess` (effective policy `allValues: DENY`), so nodes could not get external IPs. A later test confirmed it: creating a plain VM was rejected with `Constraint constraints/compute.vmExternalIpAccess violated`. Fix: private nodes plus Cloud NAT.
- Two workflow runs started a minute apart collided on the Terraform state lock.
- The first "fix" commit contained only an error log file. The Terraform changes were never committed, so the next run behaved like the old code. Always check `git show --stat HEAD` before pushing.
- Cancelling a running destroy did **not** stop it: the requests already sent to Google kept running, and the node pools and two fleet features were deleted. Recovery: wait for the operations to finish, clear the stale lock, plan, apply.

**Concepts:** Anthos → GKE Enterprise rebranding, Standard vs Autopilot, VPC-native clusters, release channels, Workload Identity Federation for GKE

---

## Phase 3: Fleet Management ✅

🔧 **Done**
- Both memberships listed in Console and CLI
- Fleet features active: `authorizer`, `configmanagement`, `fleetobservability`, `metering`, `policycontroller`, `rbacrolebindingactuation`, `servicemesh`, `workloadidentity`
- Cluster access through Connect Gateway (`kubectl get nodes` worked)

**Notes**
- `kubectl exec` through Connect Gateway returned a 400 error. Use the direct `gke_...` contexts for `exec`.
- Fleet scopes and teams were originally concept-only and were later built (see Extras).

---

## Phase 4: GitOps with Config Sync ⚠️

🔧 **Done**
- Config Sync installed on both clusters through the Console
- A `RootSync` pointing at `config-sync-repo/` in this repo, applied with `kubectl` (the `gcloud ... config-management apply` route needs the `beta` component, which could not be installed without admin rights)
- Synced a `demo` namespace and a default-deny NetworkPolicy to both clusters
- Drift correction shown on cluster-b: the NetworkPolicy was deleted and recreated within about a minute

**What went differently**
- A file written with PowerShell's `Set-Content -Encoding utf8` got a byte-order mark and Config Sync rejected it (`KNV2010: missing field "apiVersion"`), which blocked the whole sync. Fix: write repo files without a BOM.
- `nomos` was not used. `kubectl get rootsync` and `kubectl describe rootsync` showed status and errors.
- A fleet-level check (`gcloud container fleet config-management describe`) shows the `configmanagement` feature `ACTIVE` with an empty `spec` and no per-membership state, which is consistent with the sync being driven by the `RootSync` created with `kubectl` and not by a fleet config. The fleet view therefore does not report sync status here. The Console had shown 2/2 clusters with Config Sync enabled right after install, and that difference was not investigated.

**Concepts:** GitOps, RootSync vs RepoSync, unstructured format, drift correction

---

## Phase 5: Policy as Code with Policy Controller

🔧 **Done**
- Policy Controller enabled per cluster (the fleet-wide command failed with an internal error, the per-membership command with `--location` worked)
- Constraints delivered through Config Sync: `no-privileged-containers` (deny) and `pods-must-have-app-label` (dryrun), scoped to the `demo` namespace
- Deny demo: a privileged pod was rejected by the webhook on **both** clusters
- Audit demo: an unlabeled pod was allowed and then listed under `Violations` on **both** clusters
- The built-in policy bundle constraints (all in dryrun) also appear

**Concepts:** ConstraintTemplates vs Constraints, deny vs dryrun, admission control

---

## Phase 6: Cloud Service Mesh ⚠️

🔧 **Done (on cluster-b only)**
- Managed Cloud Service Mesh enabled on both clusters (revision `asm-managed`, `TRAFFIC_DIRECTOR` control plane)
- Demo apps in `mesh-demo`: `httpbin`, `client`, `sleep-allowed`, `sleep-denied`, `webapp`
- Sidecar injection: pods reach 2/2; the first pods showed 1/2 until the control plane finished provisioning
- Strict mTLS: a caller outside the mesh was rejected (curl exit code 56)
- AuthorizationPolicy: `sleep-allowed` got 200, `sleep-denied` got 403, the default-service-account `client` got 403
- Canary: a baseline of 49 / 51 before any rule, then a two-Service VirtualService at a configured 90/10 measured **447 / 53** over 500 requests (an earlier 100-request sample gave 82 / 18)
- Console Service Mesh page: service list and topology

**What went differently**
- Config changes on the managed mesh took minutes to reach running proxies, and tests run right after applying gave misleading results (a 503, policies that did not apply). Restarting the affected pods picked up config quickly.
- A VirtualService with a subset-based DestinationRule returned 503 even with `ISTIO_MUTUAL`. The same split written with two Services worked. The cause was not found.

⬜ **Not done:** SLO views. 📖 **Concept only:** ambient mesh, mesh CA options

---

## Phase 7: Multi-Cluster Networking ✅

🔧 **Multi-cluster Services**
- MCS enabled on the fleet, `hello` exported from both clusters
- A pod in Mumbai reached a service in Singapore through `hello.mcs-demo.svc.clusterset.local`
- Merged endpoints: 53 / 47 split between clusters
- Failover: with cluster-b scaled to zero, 50 of 50 answers came from cluster-a

🔧 **External multi-cluster Gateway** (`gke-l7-global-external-managed-mc`, config cluster `cluster-a`)
- Path routing: `/a` → cluster-a, `/b` → cluster-b, default path → nearest region (70 of 70 from cluster-a for a client in India)
- Failover through the load balancer: after cluster-a went to zero, one 503 and then cluster-b answered by the next sample (samples 20 s apart); answers returned to cluster-a within about 30 s of its pods becoming ready
- Weighted split on `/split` at 80/20: **157 / 43** and **156 / 44** over 200 requests each

**What went differently**
- MCS first failed: the importer IAM binding was in the wrong member format (`serviceAccount:...svc.id.goog[...]`). With no endpoint slices, calls to the ClusterSetIP were refused. The documented `principal://...` binding plus an importer restart fixed it.
- A new Gateway took about 10 minutes to serve (connection reset, then 502, then 200).
- Route changes took minutes to apply. Tests run too soon returned 200 of 200 from one cluster and then 200 of 200 from the other, which looked like broken weights but was stale rules.
- Docs say MCS creates Cloud DNS zones, but `gcloud dns managed-zones list` was empty in this project.

**Concepts:** ServiceExport and ServiceImport, `clusterset.local` DNS, config cluster, global load balancing

---

## Phase 8: Security and Governance Extras ⚠️

🔧 **Done**
- Security Posture feature shows 2/2 clusters healthy
- Node service account checked: the node pools use the Compute Engine **default** service account, which has no direct role bindings at the project or organization level (the hierarchy has no folder). Deny policies and group-based access were not checked. The effective organization policy `iam.automaticIamGrantsForDefaultServiceAccounts` is enforced, which is consistent with the default service account not receiving the automatic Editor role.
- Binary Authorization in dry-run on cluster-b: a policy of `ALWAYS_DENY` with `DRYRUN_AUDIT_LOG_ONLY` admitted the pod and logged `'nginx' : Denied by an ALWAYS_DENY admission rule`. The policy was then restored to `ALWAYS_ALLOW` (the original policy was not exported first, so this assumes the default).

⬜ **Not done:** replacing the node service account with a least-privilege one (it would recreate the node pools)

---

## Phase 9: Hybrid and Multi-Cloud (Theory) 📖

To be written in the article:
- **Google Distributed Cloud** on bare metal, VMware, and air-gapped or edge, and why it needs your own hardware
- **Attached clusters** (registering EKS, AKS or other conformant clusters into a fleet)
- Status of Anthos on AWS/Azure (deprecated in March 2025, shutdown planned for March 2027)
- Pricing model: cloud vs on-prem vCPU rates (check current pricing before quoting)
- When to use Anthos/GKE Enterprise and when plain GKE is enough

`cluster-b` acted as the stand-in for a "remote" environment, since real on-prem hardware is not available in a free trial.

---

## Extras (all done)

| Extra | What was shown | Result |
|---|---|---|
| **Gateway weighted split** | Canary at the load balancer, compared with the mesh canary | 80/20 configured, 157 / 43 and 156 / 44 measured |
| **RepoSync** | Namespace-scoped GitOps for `team-a` from `team-a-repo/`, with a RoleBinding for `ns-reconciler-team-a` | Synced on both clusters. A file with `namespace: demo` was rejected with `KNV1058`. The sync stayed at the last good commit during the error and recovered once the file was removed |
| **Workload Identity** | Direct access for a Kubernetes service account to a bucket, with no keys | `reader` printed the file, `stranger` got HTTP 403 |
| **Custom ConstraintTemplate** | `K8sRequireOwner` written in Rego and shipped through Git | Unlabeled ConfigMap denied on both clusters. The audit flags the existing `kube-root-ca.crt` ConfigMap |
| **Fleet scopes and teams** | Scope `team-checkout`, both clusters bound, fleet namespace `checkout-ns` | The namespace appeared on both clusters with `fleet.gke.io/fleet-scope=team-checkout`. Team member access was not set up |
| **Binary Authorization dry-run** | Supply chain control in audit-only mode | See Phase 8 |

---

## Phase 10: Cost Review and Cleanup ⬜

**Not started. Nothing has been deleted yet.** The order matters because deleting fleet ingress while a Gateway exists can leave load balancer resources behind.

1. Restore the Binary Authorization policy (already done once, confirm)
2. Delete the `HTTPRoute` and `Gateway`, then confirm the `gkemcg1-*` load balancer resources are gone
3. Delete the `ServiceExport` objects (`hello` on both clusters, `hello-a`, `hello-b`)
4. Delete the fleet scope objects: namespace `checkout-ns`, both membership bindings, then scope `team-checkout`
5. Wait for MCS to report no exports, then disable MCS and fleet ingress (without `--force`)
6. Delete the bucket `gs://gcp-anthos-fleet-wi-demo`
7. Run `terraform destroy` through GitHub Actions once, and do not cancel it
8. Leftover checks: clusters, instances, routers, networks, firewall rules, addresses, disks, forwarding rules, backend services, network endpoint groups and DNS zones should all be empty

**Left behind on purpose or by design (near-zero cost):** the Terraform state bucket, the `tf-github-actions` service account and Workload Identity Federation pool, budget alerts, project-level IAM bindings added during the lab (MCS importer in two member formats, `container.admin` for the multi-cluster ingress service agent), and the Policy Controller fleet feature.

**Cost record (fill in):**
- Trial credit at the start: ₹7,869 remaining of ₹28,694 (from the Billing page)
- Real total spend: _take from Billing → Reports, filtered to `gcp-anthos-fleet`_
- The trial banner lagged behind real usage during the lab, so do not quote it

---

## Repo layout

| Path | Contents |
|---|---|
| `terraform/` | VPC, subnets, NAT, clusters, node pools, fleet features |
| `config-sync-repo/` | Synced by the RootSync: namespaces, policies, custom template and constraint |
| `team-a-repo/` | Synced by the RepoSync into the `team-a` namespace |
| `fleet-config/` | `apply-spec.yaml` (unused, gcloud beta was not available) and `rootsync.yaml` |
| `.github/workflows/` | `terraform.yml` (plan, apply, destroy through Workload Identity Federation) |
| `docs/` | This plan |

---

## Known gaps and caveats for the article

- Mesh demo, strict mTLS, AuthorizationPolicy, canary and Binary Authorization ran on **cluster-b only**
- All timings and splits are single runs with samples 20 seconds or more apart
- The root cause of the subset-based DestinationRule 503 is unknown
- The node service account finding covers direct role bindings at project and organization level only (no deny policies or group-based access)
- Cloud DNS zones were not created by MCS in this project, which differs from the docs
- Mesh SLO views were not tried

---

## Article Structure

| Section | Source |
|---|---|
| Why Anthos became GKE Enterprise | Phase 2 concepts |
| Architecture diagram | Phases 2 and 3 |
| Terraform and GitHub Actions setup | Phases 1 and 2 |
| GitOps with Config Sync, RootSync and RepoSync | Phase 4 and extras |
| Guardrails with Policy Controller, including a custom template | Phase 5 and extras |
| Zero-trust with Service Mesh | Phase 6 |
| Multi-cluster services, Gateway, failover and traffic splits | Phase 7 |
| Identity and supply chain: Workload Identity, Binary Authorization | Phase 8 and extras |
| Teams with fleet scopes | Extras |
| Hybrid options and when to use Anthos | Phase 9 |
| What went wrong and what it taught | Notes under each phase |
| Real cost breakdown | Phase 10 |
