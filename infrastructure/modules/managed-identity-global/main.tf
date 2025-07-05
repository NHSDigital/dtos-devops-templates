
module "global_uami" {
  source = "../managed-identity"

  uai_name            = join("-", [var.identity_prefix, var.environment])
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_role_assignment" "global_uami_role_assignments" {
  for_each = {
    for item in flatten([
      for grp in local.grouped_role_assignments : [
        for role in grp.roles : {
          role  = role
          scope = grp.scope
        }
      ]
    ]) : "${item.scope}-${item.role}" => item
  }

  principal_id         = var.principal_id != null ? var.principal_id : module.global_uami.principal_id
  role_definition_name = each.value.role
  scope                = each.value.scope
}

locals {
  default_roles = {
    "keyvault" = [
      "Key Vault Secrets User"
    ]
    "storage" = [
      "Storage Blob Data Reader",
      "Storage Table Data Contributor",
      "Storage Queue Data Contributor"
    ]
    "sql" = [
      "SQL DB Contributor"
    ]
  }

  # Discover the type of the resource based on well-known ID patterns in Azure
  resource_tuples = [
    for rid in var.resource_ids : {
      id = rid
      type = (
        can(regex("Microsoft.KeyVault/vaults", rid)) ? "keyvault" :
        can(regex("Microsoft.Storage/storageAccounts", rid)) ? "storage" :
        can(regex("Microsoft.Sql/servers", rid)) ? "sql" :
        can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+$", rid)) ? "resource-group" :
        can(regex("^/subscriptions/[^/]+$", rid)) ? "subscription" :
        "unknown"
      )
    }
    if rid != "" && rid != null
  ]

  scoped_role_map = {
    for rt in local.resource_tuples :
    rt.id => distinct(
      lookup(var.custom_resource_roles, rt.type, lookup(local.default_roles, rt.type, []))
    )
  }

  # We group by scope to reduce the number of assignments made
  grouped_role_assignments = [
    for scope, roles in local.scoped_role_map : {
      scope = scope
      roles = roles
    }
  ]
}
