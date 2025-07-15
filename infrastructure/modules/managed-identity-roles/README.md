# Module: User Assigned Managed Identity Standard RBAC Role Definitions

## Overview

This Terraform module creates a simple custom role definition with a default set of permissions in each environment specified in the `.tfvars` file. Only the *minimal RBAC role assignments* for least-privilege access to resources like SQL Servers, Key Vaults, and Storage Accounts are specified.

### Features

* Applies RBAC roles using least privilege, for example `Key Vault Secrets User`

## Role Definitions

Note: *The permissions assigned to the custom role definitions are taken from Microsoft's documentation. Please refer to the URL references specified for additional permissions*

The minimal permissions are taken from the following standard Azure roles:

* For **[Azure Key Vaults](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/security#key-vault-reader)**

  * Certificate User
  * Crypto User
  * Secrets User

* For **[Storage Accounts](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/storage#storage-queue-data-contributor)**
  * Storage Blob Data Reader
  * Storage Table Data Reader
  * Storage Queue Data Reader
  * Storage Queue Data Message Processor
  * Storage Queue Data Message Sender
  * Storage Queue Data Reader

* For **[SQL Servers](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/databases)**
  * (trimmed-down version of SQL DB Contributor and SQL Server Contributor)

* For **[Service Bus]()**
  * Azure Service Bus Data Receiver
  * Azure Service Bus Data Sender

* For **[Event Grid]()**
  * Event Grid Data Sender

## Module

### Example Usage

```arm
module "example" {
  source = "../managed-identity-roles"

  # Assign at the group level
  assignable_scopes = [azurerm_resource_group.main.id]

  # Apply to the subscription level
  role_name         = "My Custom Product Role for (${var.environment})"
  role_scope_id     = local.subscription_scope_id

  location          = each.key
  environment       = var.environment
  tags              = var.tags
}
```

### 📥 Inputs

| Name | Type| Description | Default |
|-|-|-|-|
|`environment` | string | A code of the environment in which to create the user-assigned identity and role assignments. | |
| `location` |string| The region where the user assigned identity must be created. | |
| `role_name` | string | A custom name to assign to this role definition. | |
| `role_scope_id` | string | Ideally, the identifier of a subscription id, however it can also be a resource group identifier. | |
|`tags`| map(string) | Resource tags to be applied throughout the deployment. | default(null) |

### 📤Outputs

| Name | Description |
|------|-------------|
| `role_definition_id` | The resource definition ID assigned to this custom role definition. |

### Review & Approval Guidance

After running the default global role assignments, please consider validating the assigned roles output after Terraform plan/apply stage to confirm all scopes and roles align with least-privilege access principles.

If a Pull Request modifies the permissions of the role definition, it's recommended to perform all user acceptance testing to ensure the access to required resources remains valid.

## 💡 Best Practices

1. A best practice approach for managing security is to prefer centralised identity management using security groups or custom role definitions (as exposed in this module).

1. Also, consider not mixing user assigned and system-assigned identities in the same application.

1. Be mindful to *periodically audit* assigned roles and rotate access scopes where possible.
