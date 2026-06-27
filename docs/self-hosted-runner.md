# Self-Hosted Runner Design

## Goal

Move Terraform execution from the developer laptop into the Azure landing zone network.

The self-hosted runner runs inside `snet-runners` and executes CI/CD jobs for Terraform validation, planning, and eventually applying infrastructure changes — with the Terraform state accessed privately and no inbound public exposure.

---

## Target Design

```text
GitHub Actions
     |
     | outbound runner connection over HTTPS 443
     v
Self-hosted runner VM  (snet-runners, no public IP)
     |
     | private DNS resolution (privatelink.blob.core.windows.net)
     v
Private Endpoint for Terraform state Storage Account
     |
     v
Azure Blob Storage backend  (stgitopslzdev07522e / tfstate)
```

The runner never requires inbound access from the internet. It initiates the outbound connection to GitHub itself.

---

## Runner Placement

| Setting   | Value                              |
| --------- | ---------------------------------- |
| Subnet    | `snet-runners`                     |
| VNet      | `vnet-gitops-lz-dev-hub`           |
| Public IP | No                                 |
| Identity  | System-assigned managed identity   |
| OS        | Ubuntu Linux                       |
| Purpose   | Terraform CI/CD execution          |

---

## Network Requirements

The runner needs:

1. Outbound HTTPS (443) to GitHub
2. Outbound HTTPS (443) to Azure Resource Manager (`management.azure.com` — public endpoint)
3. Private access to the Terraform state Storage Account (via Private Endpoint)
4. Private DNS resolution for `privatelink.blob.core.windows.net`

The runner does **not** need inbound public access.

> Note on outbound: Azure is moving away from implicit default outbound internet access for VMs, so the runner needs an **explicit** egress path (NAT Gateway or Azure Firewall). Relying on Azure's default outbound access is not a durable design.

---

## Egress Design

Target (production-like) design routes runner egress through Azure Firewall so outbound traffic can be filtered and logged:

```text
snet-runners -> rt-gitops-lz-dev-egress -> Azure Firewall -> Internet
```

Planned route added to `rt-gitops-lz-dev-egress` (already associated with `snet-runners`):

```text
0.0.0.0/0 -> Azure Firewall private IP
```

This is the strongest portfolio story — it demonstrates FQDN-based egress control, centralized logging, and hub-spoke routing. See **Cost Considerations** below before deploying it 24/7.

---

## Cost Considerations

Egress option costs differ by roughly an order of magnitude. Approximate monthly fixed cost (US pricing, deployment fee only — data processing is extra; verify in the Azure pricing calculator as rates change):

| Option                     | Fixed cost (24/7)        | Data processing | Notes                                         |
| -------------------------- | ------------------------ | --------------- | --------------------------------------------- |
| Azure Firewall — Standard  | ~$900/mo ($1.25/hr)      | ~$0.016/GB      | Best demo value; FQDN filtering + logging     |
| Azure Firewall — Basic     | ~$290/mo ($0.395/hr)     | ~$0.065/GB      | Cheaper; no autoscale, lower throughput        |
| NAT Gateway + Public IP    | ~$35/mo ($0.045/hr + IP) | ~$0.045/GB      | Outbound SNAT only — no filtering or L7 control |

Implications for a dev/portfolio subscription:

- **Azure Firewall left running burns ~$900/mo** (Standard) regardless of traffic. That is the single most expensive line item in this project.
- **Recommended approach:** keep Firewall as the *documented target architecture*, but deploy it only during active work sessions and `terraform destroy` the firewall afterward — or use the **Basic** SKU. Document it once (screenshots, logs, route table), then tear it down.
- **NAT Gateway (~$35/mo)** is a legitimate, production-grade outbound option and the cheap path if the runner just needs to reach GitHub and ARM. It does not provide egress filtering, so it is a weaker portfolio demonstration than Firewall — but it is the pragmatic default for keeping the lab cheap.

Being explicit about this trade-off is itself a defensible engineering decision, not a shortcut.

---

## Authentication Model

The runner VM uses a **system-assigned managed identity**. Two authentication paths:

1. Managed identity → AzureRM provider authentication (creating/updating resources)
2. Entra ID + RBAC → backend access to the state Storage Account

Required permissions:

| Scope                                        | Role                                   |
| -------------------------------------------- | -------------------------------------- |
| Terraform state Storage Account              | `Storage Blob Data Contributor`        |
| Landing zone resource group (or subscription)| `Contributor` or a narrower custom role |

For this dev project, `Contributor` on the project resource group is acceptable. For production, prefer a narrower custom role.

---

## Terraform State Access

The backend already uses:

```hcl
use_azuread_auth = true
```

So the runner identity reads/writes/locks the remote state blob via Azure RBAC instead of Storage Account keys. Once the runner operates from inside the VNet, public network access on the state Storage Account can be disabled.

---

## Security Principles

- No public IP on the runner VM
- No inbound SSH from the internet
- Runner initiates the outbound connection to GitHub
- Terraform state accessed privately through Private Endpoint
- RBAC-based access instead of access keys
- Egress controlled (NAT Gateway or Azure Firewall) rather than implicit
- Diagnostics sent to Log Analytics (`law-gitops-lz-dev-core`)

---

## Implementation Order

1. Choose the egress option (see Cost Considerations)
2. Deploy the egress resource:
   - **Firewall path:** deploy Azure Firewall in `AzureFirewallSubnet`, add a firewall policy allowing required outbound FQDNs (GitHub, ARM, package repos), add route `0.0.0.0/0 -> Azure Firewall private IP` to `rt-gitops-lz-dev-egress`
   - **NAT Gateway path:** deploy NAT Gateway + Standard public IP, associate with `snet-runners`
3. Deploy runner VM in `snet-runners` (no public IP)
4. Enable system-assigned managed identity
5. Assign RBAC to the runner identity
6. Install Terraform, Azure CLI, Git, and the GitHub Actions runner agent
7. Register the runner to the GitHub repository
8. Add a GitHub Actions workflow for `terraform plan` on pull requests
9. Test private access to the Terraform state Storage Account
10. Disable public network access on the state Storage Account

---

## Temporary Dev Alternative

The cheapest interim option is a runner VM with NAT Gateway egress (~$35/mo) or, very temporarily, direct outbound access before any egress resource exists.

This is not the target architecture. The documented target remains:

```text
runner -> Azure Firewall -> Internet
```

Deploy the Firewall to demonstrate and document it, then revert to the cheaper egress for ongoing use.
