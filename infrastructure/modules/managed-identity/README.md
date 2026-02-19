# Managed Identity Module

Creates an Azure User-Assigned Managed Identity.

## Usage

```hcl
module "managed_identity" {
  source = "../../modules/managed-identity"

  resource_group_name = "rg-myapp-prod"
  location            = "uksouth"
  uai_name            = "mi-myapp-prod"

  tags = {
    environment = "production"
    managed_by  = "terraform"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 3.0 |

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `resource_group_name` | The name of the resource group in which to create the Identity | `string` | Yes | - |
| `location` | Azure region for the resource | `string` | Yes | - |
| `uai_name` | The name of the user assigned identity (3-128 chars, alphanumeric, hyphens, underscores) | `string` | Yes | - |
| `tags` | Resource tags to be applied | `map(string)` | No | `{}` |

### Naming Constraints

The `uai_name` must:
- Be between 3 and 128 characters
- Start with an alphanumeric character
- End with an alphanumeric character or underscore
- Contain only alphanumeric characters, hyphens, and underscores

## Outputs

| Name | Description |
|------|-------------|
| `id` | The resource ID of the User Assigned Identity |
| `name` | The name of the User Assigned Identity |
| `principal_id` | The Principal ID (Object ID) for the Service Principal associated with this Identity |
| `client_id` | The Client ID (Application ID) for the Service Principal associated with this Identity |

## Example: Assigning to a Function App

```hcl
module "managed_identity" {
  source = "../../modules/managed-identity"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  uai_name            = "mi-funcapp-prod"
}

resource "azurerm_linux_function_app" "example" {
  # ... other config ...

  identity {
    type         = "UserAssigned"
    identity_ids = [module.managed_identity.id]
  }
}
```

## Example: Granting Key Vault Access (RBAC)

```hcl
module "managed_identity" {
  source = "../../modules/managed-identity"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  uai_name            = "mi-myapp-prod"
}

resource "azurerm_role_assignment" "keyvault_secrets" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.managed_identity.principal_id
}
```

## Testing

This module includes automated tests using Terratest.

```bash
cd tests
go test -v ./...
```

Tests validate:
- Valid input configurations are accepted
- Invalid identity names are rejected by validation rules

## Documentation

Auto-generated documentation is available in [tfdocs.md](./tfdocs.md).
