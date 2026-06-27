# Architecture

## Overview

This project deploys a hub-style Azure landing zone foundation for the `dev` environment.

The current architecture focuses on:

* Modular Terraform structure
* Remote Terraform state in Azure Blob Storage
* Entra ID and RBAC-based backend authentication
* Private Endpoints and Private DNS
* Subnet segmentation
* NSG baseline rules
* Route table foundation for future forced egress
* Central diagnostics through Log Analytics

---

## High-Level Architecture

```mermaid
flowchart TD
    Dev[Developer Laptop<br/>Terraform + Azure CLI] --> Backend[Azure Blob Remote State<br/>stgitopslzdev07522e / tfstate]

    Backend --> RG[Resource Group<br/>rg-gitops-lz-dev-core]

    RG --> VNet[Hub VNet<br/>vnet-gitops-lz-dev-hub<br/>10.10.0.0/16]

    VNet --> Runners[snet-runners<br/>10.10.10.0/24<br/>Future self-hosted runners]
    VNet --> Shared[snet-shared<br/>10.10.1.0/24<br/>Future shared services]
    VNet --> PE[snet-private-endpoints<br/>10.10.2.0/24]
    VNet --> FW[AzureFirewallSubnet<br/>10.10.100.0/26<br/>Reserved for future Azure Firewall]

    PE --> KVPE[Key Vault Private Endpoint]
    PE --> BlobPE[Storage Blob Private Endpoint]

    KVPE --> KV[Key Vault<br/>kv-gitopslzdev-07522e]
    BlobPE --> SA[Storage Account<br/>stgitopslzdev07522e]

    KV --> LAW[Log Analytics Workspace<br/>law-gitops-lz-dev-core]
    SA --> LAW
    Runners --> RT[Route Table<br/>rt-gitops-lz-dev-egress]
    Shared --> RT
```

---

## Network Layout

| Component                |             CIDR | Purpose                            |
| ------------------------ | ---------------: | ---------------------------------- |
| Hub VNet                 |   `10.10.0.0/16` | Main landing zone network          |
| `snet-runners`           |  `10.10.10.0/24` | Future self-hosted CI/CD runners   |
| `snet-shared`            |   `10.10.1.0/24` | Future shared services             |
| `snet-private-endpoints` |   `10.10.2.0/24` | Private Endpoint NICs              |
| `AzureFirewallSubnet`    | `10.10.100.0/26` | Reserved for future Azure Firewall |

---

## Private Access Flow

```mermaid
flowchart LR
    Runner[Future Self-Hosted Runner<br/>snet-runners] --> DNS[Private DNS Zones]
    DNS --> BlobDNS[privatelink.blob.core.windows.net]
    DNS --> KVDNS[privatelink.vaultcore.azure.net]

    BlobDNS --> BlobPE[Storage Blob Private Endpoint]
    KVDNS --> KVPE[Key Vault Private Endpoint]

    BlobPE --> State[Terraform State Storage Account]
    KVPE --> Vault[Key Vault]
```

Current state:

* Private Endpoints already exist for Key Vault and Storage Blob.
* Private DNS zones are linked to the hub VNet.
* The Storage Account still has public network access enabled because Terraform currently runs from the developer laptop.
* After a self-hosted runner is deployed inside `snet-runners`, Terraform can run privately from inside the VNet.

---

## Terraform State Flow

```mermaid
sequenceDiagram
    participant User as Developer Laptop
    participant TF as Terraform
    participant Blob as Azure Blob Storage Backend
    participant Azure as Azure Resource Manager

    User->>TF: terraform plan/apply
    TF->>Blob: Authenticate with Entra ID
    TF->>Blob: Acquire state lock
    TF->>Blob: Read remote state
    TF->>Azure: Create/update Azure resources
    TF->>Blob: Write updated state
    TF->>Blob: Release state lock
```

The backend uses:

```hcl
use_azuread_auth = true
```

This means Terraform reads, writes, and locks the state blob using Entra ID authentication and Azure RBAC.

---

## Security Decisions

| Area                    | Decision                                            |
| ----------------------- | --------------------------------------------------- |
| Terraform state         | Stored remotely in Azure Blob Storage               |
| Backend authentication  | Entra ID + RBAC                                     |
| State access role       | Storage Blob Data Contributor                       |
| Key Vault access        | RBAC authorization enabled                          |
| Key Vault public access | Disabled                                            |
| Storage public access   | Temporarily enabled until runner exists inside VNet |
| Private access          | Private Endpoints for Key Vault and Storage Blob    |
| DNS                     | Private DNS zones linked to hub VNet                |
| Observability           | Diagnostic settings sent to Log Analytics           |

---

## Current Limitations

The current architecture is intentionally incomplete. The following items are planned but not deployed yet:

* Self-hosted CI/CD runner
* CI/CD pipeline
* Azure Firewall
* Forced egress routing
* Disabled public access for the Terraform state Storage Account
* Azure Policy baselines
* Python validation scripts

---

## Target Future Flow

```mermaid
flowchart TD
    GitHub[GitHub Repository] --> PR[Pull Request]
    PR --> Plan[CI Pipeline<br/>fmt + validate + plan]

    GitHub --> Main[Main Branch]
    Main --> Approval[Manual Approval]
    Approval --> Runner[Self-Hosted Runner<br/>snet-runners]
    Runner --> State[Terraform State<br/>Private Storage Access]
    Runner --> Azure[Azure Resource Manager]

    Runner --> FW[Azure Firewall]
    FW --> Internet[Controlled Internet Egress]
```

Target model:

1. Developers open pull requests.
2. CI runs `terraform fmt`, `terraform validate`, and `terraform plan`.
3. Approved merges trigger controlled `terraform apply`.
4. Terraform runs from a self-hosted runner inside the VNet.
5. The state Storage Account public network access is disabled.
6. Outbound traffic is forced through Azure Firewall.
