
resource "azurerm_user_assigned_identity" "global_uami" {
  name                = "${var.identity_prefix}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group
  tags                = var.tags
}

resource "azurerm_role_assignment" "global_uami_role_assignments" {
  for_each = {
    for assignment in local.all_role_assignments :
    "uami-${var.environment}-${replace(lower(assignment.role_definition_name), " ", "-")}-${substr(md5(assignment.scope), 0, 6)}" => {
      scope                = assignment.scope
      role_definition_name = assignment.role_definition_name
    }
  }

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
  kv_ids    = try(var.key_vault_ids, {})
  st_ids    = try(var.storage_ids, {})
  sql_ids   = try(var.sql_server_ids, {})

  role_assignments_kv = [
    for region, obj in local.kv_ids : {
      scope                = obj.key_vault_id
      role_definition_name = "Key Vault Secrets User"
    }
    if try(obj.key_vault_id, null) != null
  ]

  role_assignments_st = flatten([
    for region, obj in local.st_ids : [
      {
        scope                = obj.storage_account_id
        role_definition_name = "Storage Blob Data Reader"
      },
      {
        scope = obj.storage_account_id
        role_definition_name = "Storage Table Data Reader"
      },
      {
        scope = obj.storage_account_id
        role_definition_name = "Storage Queue Data Reader"
      }
    ]
    if try(obj.storage_account_id, null) != null
  ])

  role_assignments_db = flatten([
    for region, obj in local.sql_ids : [
      {
        scope                = obj.sql_server_id
        role_definition_name = "SQL DB Contributor"
      }
    ]
    if try(obj.sql_server_id, null) != null
  ])

  all_role_assignments = concat(
    var.assignments,
    local.role_assignments_kv,
    local.role_assignments_st,
    local.role_assignments_db
  )
}
