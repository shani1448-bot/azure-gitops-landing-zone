# Azure GitOps Landing Zone

A modular Azure landing zone built with Terraform and GitOps principles. The project provisions a hub-style cloud foundation as Infrastructure as Code with secure defaults, remote Terraform state, RBAC-based access, private networking, and centralized diagnostics — with a clear roadmap toward CI/CD automation and self-hosted runners.

Built as a DevOps / Cloud Engineering portfolio project.

---

## Architecture Overview

```
Developer Laptop
     |
     | Terraform / Azure CLI (Entra ID auth + RBAC)
     v
Azure Blob Remote State  (stgitopslzdev07522e / tfstate)
     |
     v
Hub VNet  vnet-gitops-lz-dev-hub  (10.10.0.0/16)
├── snet-runners            10.10.10.0/24   -> future self-hosted CI/CD runners
├── snet-shared             10.10.1.0/24    -> future shared services
├── snet-private-endpoints  10.10.2.0/24
│   ├── Key Vault Private Endpoint
│   └── Storage Blob Private Endpoint
└── AzureFirewallSubnet     10.10.100.0/26  -> reserved for future Azure Firewall
```

Deployed components:

- Resource Group
- Hub Virtual Network with segmented subnets
- Network Security Groups + baseline rules
- Route Table foundation
- Log Analytics Workspace
- Key Vault (private, RBAC-authorized)
- Key Vault Private Endpoint + Private DNS Zone
- Terraform state Storage Account + blob container
- Storage Blob Private Endpoint + Private DNS Zone
- Diagnostic settings across NSGs, Key Vault, and the state Storage Account
- RBAC role assignment for Terraform state access

---

## Repository Structure

```text
azure-gitops-landing-zone/
└── terraform/
    ├── environments/
    │   └── dev/
    │       ├── backend.tf
    │       ├── providers.tf
    │       ├── variables.tf
    │       ├── locals.tf
    │       ├── main.tf
    │       ├── outputs.tf
    │       └── .terraform.lock.hcl
    └── modules/
        ├── resource-group/
        ├── vnet/
        ├── nsg/
        ├── route-table/
        ├── log-analytics/
        ├── diagnostic-setting/
        ├── key-vault/
        ├── private-dns-zone/
        ├── private-endpoint/
        ├── storage-account/
        └── role-assignment/
```

**Design principle:**

- `terraform/environments/dev` — the root module where `terraform init/plan/apply` runs.
- `terraform/modules/*` — reusable building blocks, one per Azure concern.

This keeps the environment readable while making the infrastructure reusable and easy to extend to new environments.

---

## Environment

| Setting     | Value          |
|-------------|----------------|
| Environment | `dev`          |
| Location    | `westeurope`   |
| Name prefix | `gitops-lz-dev`|

The subscription ID is passed via an environment variable rather than hardcoded:

```bash
export TF_VAR_subscription_id=$(az account show --query id -o tsv)
```

> Note: `terraform init` can succeed without this variable, but `plan` and `apply` require it because the AzureRM provider needs `subscription_id`. Re-export it in every new terminal session.

---

## How to Run

From the `dev` environment folder:

```bash
cd terraform/environments/dev

export TF_VAR_subscription_id=$(az account show --query id -o tsv)

terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

---

## Remote Terraform State

State is stored remotely in Azure Blob Storage, configured in `terraform/environments/dev/backend.tf`:

| Property        | Value                       |
|-----------------|-----------------------------|
| Resource Group  | `rg-gitops-lz-dev-core`     |
| Storage Account | `stgitopslzdev07522e`       |
| Container       | `tfstate`                   |
| Blob            | `dev.terraform.tfstate`     |

The backend authenticates with Entra ID instead of Storage Account keys:

```hcl
use_azuread_auth = true
```

The executing user holds the **Storage Blob Data Contributor** role on the state Storage Account, assigned through the `role-assignment` module. Terraform itself reads, writes, and locks the state blob using this identity.

**State locking** is active — Terraform acquires a lock before `plan`/`apply` so two processes cannot mutate the same state concurrently (`Acquiring state lock... / Releasing state lock...`).

> Distinction worth noting: *provider* authentication is used to create and update Azure resources, while *backend* authentication is used by Terraform to read/write/lock the state file. They are configured separately.

---

## Networking

Hub VNet `vnet-gitops-lz-dev-hub` (`10.10.0.0/16`):

| Subnet                    | CIDR             | Purpose                              |
|---------------------------|------------------|--------------------------------------|
| `snet-runners`            | `10.10.10.0/24`  | Future self-hosted CI/CD runners     |
| `snet-shared`             | `10.10.1.0/24`   | Future shared services               |
| `snet-private-endpoints`  | `10.10.2.0/24`   | Private Endpoint NICs                |
| `AzureFirewallSubnet`     | `10.10.100.0/26` | Reserved for future Azure Firewall   |

### Network Security Groups

| NSG                                    | Subnet                    |
|----------------------------------------|---------------------------|
| `nsg-gitops-lz-dev-runners`            | `snet-runners`            |
| `nsg-gitops-lz-dev-shared`             | `snet-shared`             |
| `nsg-gitops-lz-dev-private-endpoints`  | `snet-private-endpoints`  |

`AzureFirewallSubnet` has no NSG attached, per Azure Firewall requirements.

The runners NSG includes a baseline `deny-vnet-inbound` rule: runners should initiate outbound connections, not receive inbound traffic from other subnets.

### Route Table

`rt-gitops-lz-dev-egress` is associated with `snet-runners` and `snet-shared`. No custom routes yet. Once Azure Firewall is deployed, a default route will force egress through it:

```text
0.0.0.0/0 -> Azure Firewall private IP
```

---

## Key Vault

`kv-gitopslzdev-07522e`

- RBAC authorization enabled
- Public network access **disabled**
- Private Endpoint + Private DNS enabled
- Diagnostics enabled
- Soft delete retention: 7 days
- Purge protection disabled (for dev cleanup simplicity)

Tenant ID is read dynamically:

```hcl
tenant_id = data.azurerm_client_config.current.tenant_id
```

The Key Vault name is derived deterministically for global uniqueness:

```hcl
key_vault_name = "kv-${replace(local.name_prefix, "-", "")}-${substr(replace(var.subscription_id, "-", ""), 0, 6)}"
# gitops-lz-dev -> gitopslzdev; first 6 chars of the subscription ID -> kv-gitopslzdev-07522e
```

---

## Private Endpoints & Private DNS

Private DNS zones linked to the hub VNet with `registration_enabled = false` (these zones hold Private Endpoint records, not automatic VM registration):

- `privatelink.vaultcore.azure.net`
- `privatelink.blob.core.windows.net`

| Private Endpoint               | Target                       | Subresource |
|--------------------------------|------------------------------|-------------|
| `pe-kv-gitops-lz-dev-core`     | Key Vault                    | `vault`     |
| `pe-blob-gitops-lz-dev-tfstate`| Storage Account Blob service | `blob`      |

A Private DNS A record is automatically created for each endpoint. The blob Private Endpoint prepares private access to the state Storage Account for future runners executing inside the VNet.

---

## Terraform State Storage Account

`stgitopslzdev07522e` — container `tfstate`

| Setting                          | Value       |
|----------------------------------|-------------|
| Kind                             | StorageV2   |
| Tier / Replication               | Standard / LRS |
| Minimum TLS                      | TLS 1.2     |
| Blob versioning                  | Enabled     |
| Blob soft delete                 | 7 days      |
| Container soft delete            | 7 days      |
| Container access                 | Private     |
| Shared access key                | Enabled     |
| Public network access            | **Enabled (temporary)** |

> Public network access is intentionally still enabled because Terraform currently runs from a developer laptop outside the VNet. It will be disabled once a self-hosted runner executes Terraform from inside `snet-runners`.

> Provider note: on AzureRM v4.x, `azurerm_storage_container` requires `storage_account_name` (not `storage_account_id`).

---

## Diagnostics & Observability

A reusable `diagnostic-setting` module (built on `azurerm_monitor_diagnostic_setting`) ships logs and metrics to `law-gitops-lz-dev-core`.

| Resource                | Categories                                                            |
|-------------------------|-----------------------------------------------------------------------|
| NSGs                    | `NetworkSecurityGroupEvent`, `NetworkSecurityGroupRuleCounter`        |
| Key Vault               | `AuditEvent`, `AllMetrics`                                            |
| Storage Blob service    | `StorageRead`, `StorageWrite`, `StorageDelete`, `Transaction` metric |

Storage diagnostics target the blob service resource (`.../storageAccounts/<name>/blobServices/default`), making every read/write/delete against the state blob observable. The `Capacity` metric is explicitly disabled — Azure reports it as disabled, and modeling that prevents repeated Terraform plan drift.

---

## Current Limitations (by design)

- Terraform still runs from a local machine.
- Storage Account public network access is still enabled.
- No self-hosted runner exists yet.
- CI/CD pipeline not implemented yet.
- Azure Firewall reserved but not deployed.
- Forced egress routing not yet active.
- Azure Policy baselines not yet implemented.

---

## Roadmap

1. Add architecture diagram
2. Deploy self-hosted runner in `snet-runners`
3. Add CI/CD pipeline
   - Pull request: `terraform fmt`, `validate`, `plan`
   - Main branch: approved `terraform apply`
4. Move Terraform execution into the VNet
5. Disable public network access on the state Storage Account
6. Deploy Azure Firewall + forced egress route
7. Add Azure Policy and security baselines
8. Add Python validation scripts

---

## Skills Demonstrated

Terraform · AzureRM provider · remote state · Azure Blob backend · Entra ID auth · Azure RBAC · VNet design & subnet segmentation · NSGs · route tables · Private Endpoints · Private DNS · Key Vault · Storage Account security · Log Analytics · diagnostic settings · Git/GitHub · Infrastructure as Code · GitOps-oriented operations
