# Build phases

1. **Foundation** - project, billing, budget alerts, state bucket, WIF for GitHub Actions
2. **Infra (Terraform)** - VPC, two GKE clusters, fleet registration, fleet features
3. **Config Sync** - point both clusters at `config-sync-repo/`
4. **Policy Controller** - constraint templates and a blocked-pod demo
5. **Cloud Service Mesh** - managed mesh, sample app, mTLS
6. **Multi-cluster Services / Ingress** - failover demo
7. **Cleanup** - `terraform destroy`, check LBs, disks, IPs
