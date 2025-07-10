# Module: User Assigned Managed Identity Standard RBAC Role Definitions

## Overview

This Terraform module conditionally assigns roles with a default set of permissions to a single **User Assigned Managed Identity (UAMI)** created in each environment specified in the `.tfvars` file. The *minimal RBAC role assignments* are setup to permit least-privilege access to resources like SQL Servers, Key Vaults, and Storage Accounts.

### Features

* Creates one User Assigned Managed Identity per environment
* Applies RBAC roles using least privilege, for example `Key Vault Secrets User`
* Outputs identity metadata and role assignment summary

### Benefits

This module reduces RBAC complexity, centralises identity usage, and aligns with zero-trust and Secure-by-Design principles.

## Role Definitions

This module create custom role definitions for each category of resources whose permission set we wish to manage as a collective whole.

The permissions assigned to the custom role definitions are taken from Microsof's documentation.

* **[Azure Key Vaults](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/security#key-vault-reader)**

  * Certificate User
  * Crypto User
  * Secrets User

* **[Storage Accounts](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/storage#storage-queue-data-contributor)**
  * Storage Blob Data Reader
  * Storage Table Data Reader
  * Storage Queue Data Reader
  * Storage Queue Data Message Processor
  * Storage Queue Data Message Sender
  * Storage Queue Data Reader

* **SQL Servers**
  * (placeholder)

## Module

### Example Usage

```hcl
module "example" {
 source = "./managed-identity-roles"

  uai_name            = join("-", compact(["<my_global_name>l", each.key]))
  location            = "<region_name>"
  resource_group_name = "<sample_resource_group_name>"
  environment         = var.environment
  tags                = var.tags
}
```

### 📥 Inputs

| Name | Type| Description | Default |
|-|-|-|-|
|`environment` | string | A code of the environment in which to create the user-assigned identity and role assignments. | |
| `location` |string| The region where the user assigned identity must be created. | |
| `resource_group_name` | string | A name of a resource group to locate this user assigned identity. | |
|`tags`| map(string) | Resource tags to be applied throughout the deployment. | default(null) |
| `uai_name` |string| The name of the user assigned identity. | |

### 📤Outputs

| Name | Description |
|------|-------------|
| `storage_role_definition_id` | The role definition ID containing storage permission set. |
| `keyvault_role_definition_id` | The role definition ID containing key vault permission set. |
| `sql_role_definition_id` | The role definition ID containing SQL server permission set. |
| `function_role_definition_id` | The role definition ID containing function app permission set. _**Defaults to `Contributor` role**_ |
| `reader_role_id` | The role definition ID of the _**`Reader`**_ role.

### Review & Approval Guidance

After running the default global role assignments, please consider to inspect the assigned_roles output after Terraform plan/apply stage to confirm all scopes and roles align with least-privilege access principles.

If a Pull Request modifies the role assignments, it's recommended the assignments be reviewed by a security stakeholder and the need of extended role(s) justified in PR comments.

## Handling Legacy System-Assigned Identities

This module does not remove system-assigned identities or pre-existing RBAC bindings. These must be handled manually or through targeted Terraform cleanup.

**Option 1** One-Time Manual Cleanup
Use the Azure Portal or CLI to disable system-assigned identities on apps and remove old `azurerm_role_assignment` resources.

**Option 2** Add explicit "cleanup" blocks per project via Terraform
If desired, add explicit cleanup blocks per project, for example:

```hcl
resource "azurerm_role_assignment" "remove_old" {
  count = var.cleanup_enabled ? 1 : 0

  scope              = <resource_id>
  role_definition_id = data.azurerm_role_definition.old_role.id
  principal_id       = data.azurerm_function_app.old_app.identity.principal_id

  lifecycle {
    prevent_destroy = false
  }
}
```

## 💡 Best Practices

A best practice approach for managing security is to prefer centralised identity management using this module. Also, it's not recommended to mix user assigned and system-assigned identities in the same application.

As always, it's important to *periodically audit* assigned_roles and rotate access scopes where possible.
