# Module: User Assigned Managed Identity (UAMI) & Standard RBAC Assignments

## Overview

This Terraform module provisions a **User Assigned Managed Identity (UAMI)** for a specified environment and applies **minimal RBAC role assignments** to Azure resources like SQL Servers, Key Vaults, and Storage Accounts. This follows Secure-by-Design principles and enables reuse across other Terraform services like Azure Function Apps.

## Features

* Creates one UAMI per environment
* Applies RBAC roles using least privilege, for example `Key Vault Secrets User`
* Outputs identity metadata and role assignment summary
* Designed to integrate with Azure Function Apps

## Benefits

This module reduces RBAC complexity, centralise identity usage, and aligns with zero-trust and Secure-by-Design principles. To be most impactful, consumers of this module must:

* Remove legacy system-assigned identity bindings
* Review assignments regularly

## Requirements

> Note: This module expects the `infra.tfstate` remote state to expose the following outputs:
> - `key_vault_ids` (map)
> - `storage_account_ids` (map)
> - `sql_server_ids` (map)
>
> *These must be exposed in upstream infrastructure modules for KeyVaults, Storage Accounts and SQL Servers. Please ensure their `outputs.tf` are correctly specified.*

## Example Usage

```hcl
module "gloabl_uami_rbac" {
  source = "./modules/rbac-assignment-global"

  identity_prefix  = "uami-global"
  environment      = "dev"
  location         = "uksouth"
  resource_group   = "rg-cohortmanager-dev"
  tags             = var.global_tags

  principal_id = null # optional if not delegating to another principal

# These assignments are optional and can be used to extend the default role assignments
  assignments = [
    {
      scope                = <resource id>
      role_definition_name = <resource definition name>
    },
    ...
  ]
}

resource "azurerm_linux_function_app" "cohort_app" {
  # ...
  identity {
    type         = "UserAssigned"
    identity_ids = [module.global_uami_rbac.global_uami_id]
  }
}
```

---

## Review & Approval Guidance

To ensure compliance with RBAC and security standards:

1. **Review Role Assignments**

   * Inspect `module.global_uami_rbac.assigned_roles` output after `plan` or `apply` steps.
   * Validate each role aligns with the principle of least privilege.

2. **Change Approval**

   * RBAC changes should be reviewed via Pull Request by a lead engineer or security team explaining why  enhanced  roles are required.

---

## Outputs

* `global_uami_id` is the resource ID of the UAMI.
* `global_uami_principal_id` is the principal ID of role assignment.
* `assigned_roles` is a list of RBAC assignments made.

---

## Handling System-Assigned Identity Cleanup

### Current Issue

Existing Function Apps may have

* System-assigned identities enabled on them, and
* RBAC roles granted to them

This module **does not clean up** existing identities and role assignments. This must be managed separately to avoid over-extending the current permission set.Running identity / role cleanup is a destructive process and **should not** be run every time.

A few proposals include:

#### Option 1: One-Time Manual Cleanup

Use the Azure Portal or CLI to remove old `azurerm_role_assignment` and disable system identity on Function Apps.

#### Option 2: Terraform Cleanup Block

Add a Terraform block to each project's Function App module. For example,

```hcl
resource "azurerm_role_assignment" "remove_old" {
  count = var.cleanup_enabled ? 1 : 0

  scope              = <affected_resource>
  role_definition_id = data.azurerm_role_definition.old_role.id
  principal_id       = data.azurerm_function_app.function.identity.principal_id
  lifecycle {
    prevent_destroy = false
  }
}
```

and also

```hcl
resource "azurerm_linux_function_app" "cohort_app" {
  identity {
    type = "UserAssigned"
    identity_ids = [module.uami_rbac.global_uami_id]
  }
}
```
