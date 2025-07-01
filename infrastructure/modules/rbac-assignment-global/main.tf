
resource "azurerm_user_assigned_identity" "global_uami" {
  name                = "${var.identity_prefix}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group
  tags                = var.tags
}

resource "azurerm_role_assignment" "global_uami_role_assignments" {
  for_each = var.enable_global_rbac ? {
    for idx, assignment in local.all_role_assignments : idx => assignment
  } : {}

  # This allows us to use service / group principals
  principal_id = var.principal_id != null ? var.principal_id : azurerm_user_assigned_identity.global_uami.principal_id
  role_definition_name = each.value.role_definition_name
  scope                = each.value.scope
}

# Note: using state was so that we could dynamically build a list of resources, but there are cases
# where we might miss resources. So better to be explicit and get the calling module tell us which
# resources to assign. This way Terry ensures our resources are in existence before calling this module
# data "terraform_remote_state" "infra" {
#   backend = "azurerm"
#   config = {
#     resource_group_name  = "tfstate"
#     storage_account_name = "tfstatestorage"
#     container_name       = "tfstate"
#     key                  = "infra.tfstate"
#   }
# }

locals {
  input_maps = {
    key_vault_ids = {
      map    = try(var.key_vault_ids, {}),
      id_key = "key_vault_id",
      roles  = ["Key Vault Secrets User"]
    }
    storage_ids = {
      map = try(var.storage_ids, {}),
      id_key = "storage_account_id", roles = [
        "Storage Blob Data Reader",
        "Storage Table Data Contributor",
        "Storage Queue Data Contributor"
      ]
    }
    sql_server_ids = {
      map    = try(var.sql_server_ids, {}),
      id_key = "sql_server_id",
      roles  = ["SQL DB Contributor"]
    }
    function_ids = {
      map    = try(var.function_ids, {}),
      id_key = "function_app_id",
      roles  = ["Contributor"]
    }
  }

  flattened_roles = flatten([
    for label, config in local.input_maps : [
      for region, obj in config.map : [
        for role in config.roles : {
          scope                = lookup(obj, config.id_key, null)
          role_definition_name = role
        }
        if lookup(obj, config.id_key, null) != null
      ]
    ]
  ])

  all_role_assignments = concat(
    var.assignments,
    local.flattened_roles
  )
}
