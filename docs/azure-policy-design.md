# Azure Policy Design

## Goal

The goal is to add a governance layer to the Azure GitOps Landing Zone using Azure Policy.

Terraform is currently used to create explicit infrastructure resources, including diagnostic settings for selected resources. Azure Policy will be used to enforce baseline governance requirements across the environment, starting with diagnostic settings.

This creates a stronger landing zone model:

```text
Terraform provisions infrastructure
Azure Policy enforces governance
Log Analytics centralizes observability
GitHub Actions will automate deployment later
```

---

## Why Azure Policy

Manual Terraform diagnostic settings are useful for known resources, but they do not automatically protect future resources.

Azure Policy can enforce rules such as:

* Required diagnostic settings
* Required Log Analytics destination
* Required tags
* Denied public access
* Allowed regions
* Allowed SKUs
* Required private endpoints

For this project, the first Azure Policy use case is diagnostic settings enforcement.

---

## Current Diagnostic Settings Model

The project currently creates diagnostic settings directly with Terraform for selected resources.

Current examples:

| Resource             | Diagnostic setting source |
| -------------------- | ------------------------- |
| NSGs                 | Terraform module          |
| Key Vault            | Terraform module          |
| Storage Blob service | Terraform module          |

This is explicit and easy to understand, but it does not scale well if more resources are added later.

---

## Target Diagnostic Settings Model

The target design is to use Azure Policy for governance enforcement.

```text
Resource is created
     |
     v
Azure Policy evaluates compliance
     |
     v
If diagnostic settings are missing
     |
     v
DeployIfNotExists policy deploys diagnostic settings
     |
     v
Logs are sent to Log Analytics
```

Target Log Analytics Workspace:

```text
law-gitops-lz-dev-core
```

---

## Design Principle

The project will use a phased model.

### Phase 1 — Explicit Terraform Diagnostics

Keep existing Terraform diagnostic settings for the core resources already deployed.

This keeps the project simple and predictable while building the foundation.

### Phase 2 — Azure Policy for Enforcement

Add Azure Policy assignments to enforce diagnostics on future resources.

This demonstrates governance at scale.

### Phase 3 — Reduce Manual Diagnostic Settings

After policy enforcement is tested, selected direct diagnostic-setting modules can be removed or kept only for special cases.

---

## Policy Scope

For this portfolio project, policy should initially be assigned at the resource group scope:

```text
rg-gitops-lz-dev-core
```

This keeps the blast radius small.

Later, the same pattern can be moved to:

```text
Subscription scope
Management group scope
```

---

## Policy Effect

The desired policy effect is:

```text
DeployIfNotExists
```

Meaning:

If a matching resource does not have the required diagnostic setting, Azure Policy can deploy it.

This is different from simple audit mode.

| Effect              | Meaning                               |
| ------------------- | ------------------------------------- |
| `AuditIfNotExists`  | Detect missing diagnostics only       |
| `DeployIfNotExists` | Detect and deploy missing diagnostics |
| `Disabled`          | Policy is not active                  |

For this project, the first safe step can be `AuditIfNotExists`, followed by `DeployIfNotExists` once the policy behavior is understood.

---

## Managed Identity Requirement

A `DeployIfNotExists` policy assignment needs a managed identity.

The identity is used by Azure Policy to deploy the missing diagnostic settings.

The identity needs permission to create diagnostic settings on the target resources and send logs to the Log Analytics Workspace.

Typical permissions:

| Scope                   | Permission                                 |
| ----------------------- | ------------------------------------------ |
| Target resource scope   | Create diagnostic settings                 |
| Log Analytics Workspace | Send diagnostic data / reference workspace |

For the dev portfolio environment, assignment at the resource group scope is acceptable.

---

## Remediation

Azure Policy does not automatically fix all existing resources immediately.

For existing non-compliant resources, a remediation task is usually required.

Process:

```text
Assign policy
     |
     v
Policy evaluates resources
     |
     v
Resources become compliant or non-compliant
     |
     v
Run remediation task
     |
     v
DeployIfNotExists creates missing diagnostic settings
```

This is an important operational detail.

---

## Built-in vs Custom Policies

Azure provides built-in policies for diagnostic settings for many resource types.

Where a built-in policy exists, prefer the built-in policy.

Where a built-in policy does not exist, create a custom policy.

Recommended approach for this project:

1. Start with a built-in policy for one resource type.
2. Assign it at resource group scope.
3. Send logs to `law-gitops-lz-dev-core`.
4. Validate compliance.
5. Run remediation if needed.
6. Repeat for additional resource types.

---

## Initial Candidate Resources

Good first candidates:

| Resource type                  | Reason                                            |
| ------------------------------ | ------------------------------------------------- |
| Key Vault                      | Security-sensitive resource with audit logs       |
| Azure Firewall                 | Important for network security visibility         |
| NSG                            | Useful for network flow and rule counters         |
| Storage Account / Blob service | Important because Terraform state is stored there |

Recommended first policy test:

```text
Key Vault diagnostic settings to Log Analytics
```

Reason:

Key Vault audit logs are security-relevant and easy to explain in interviews.

---

## Relationship to Existing Terraform Diagnostic Module

The existing Terraform diagnostic-setting module should not be deleted yet.

Current model:

```text
Terraform diagnostic module = explicit diagnostics for known core resources
Azure Policy = governance enforcement for missing/future diagnostics
```

This is a valid enterprise pattern.

The project can later decide whether to keep both or migrate fully to policy-driven diagnostics.

---

## Risks and Trade-offs

### Complexity

Azure Policy with `DeployIfNotExists` is harder to debug than direct Terraform resources.

Terraform errors happen during `terraform plan/apply`.

Policy remediation errors happen later through Azure Policy compliance and remediation workflows.

### Drift

If Terraform creates diagnostic settings directly and Azure Policy also tries to deploy diagnostic settings for the same resource, naming conflicts can occur.

To avoid this:

* Use clear diagnostic setting names.
* Do not apply duplicate policies to resources already managed manually unless tested.
* Start with one resource type.

### Permissions

Policy remediation requires correct managed identity permissions.

Missing permissions will result in non-compliant resources that cannot be remediated.

---

## Implementation Plan

1. Document Azure Policy design.
2. Create a reusable Terraform module for policy assignment.
3. Start with a built-in diagnostic settings policy.
4. Assign the policy at `rg-gitops-lz-dev-core` scope.
5. Use `law-gitops-lz-dev-core` as the Log Analytics destination.
6. Validate compliance.
7. Run remediation if needed.
8. Expand to additional resource types.
9. Later add custom policies for security baselines.

---

## Future Policy Baselines

After diagnostic settings, the project can add policies for:

* Required tags
* Allowed Azure regions
* Deny public network access on supported PaaS services
* Require private endpoints for selected services
* Restrict public IP creation
* Restrict VM SKUs
* Require secure transfer on Storage Accounts
* Deny overly permissive NSG rules

These policies will turn the project from infrastructure provisioning into a more complete landing zone governance model.

---

## Portfolio Value

This design demonstrates:

* Infrastructure as Code
* Cloud governance
* Observability enforcement
* Security baseline thinking
* Azure Policy usage
* Log Analytics integration
* Separation between provisioning and governance

The key architectural message:

```text
Terraform builds the environment.
Azure Policy keeps the environment compliant.
Log Analytics makes the environment observable.
```
