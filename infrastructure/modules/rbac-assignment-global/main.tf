
resource "azurerm_user_assigned_identity" "global_uami" {
  name                = "${var.identity_prefix}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group
  tags                = var.tags
}

resource "azurerm_role_assignment" "global_rbac_assignments" {
  for_each = {
    for assignment in local.all_rbac_assignments :
    "uami-${var.environment}-${assignment.role_definition_name}-${replace(assignment.scope, "/", "-")}" => {
      scope                = assignment.scope
      role_definition_name = assignment.role_definition_name
    }
  }

  # This allows us to use service / group principals
  principal_id = var.principal_id != null ? var.principal_id : azurerm_user_assigned_identity.global_uami.principal_id

  role_definition_name = each.value.role_definition_name
  scope                = each.value.scope
}

# Let's pull from remote state to dynamically
# build up a list of resources wot we can make assignments to
data "terraform_remote_state" "infra" {
  backend = "azurerm"
  config = {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstatestorage"
    container_name       = "tfstate"
    key                  = "infra.tfstate"
  }
}

locals {
  # Make sure that these resources do expose these properties in their outputs.tf files
  kv_map = data.terraform_remote_state.infra.outputs.key_vault_ids
  rbac_assignments_kv = [
    for region, kv_id in local.kv_map : {
      scope                = kv_id
      role_definition_name = "Key Vault Secrets User"
    }
  ]

  # Make sure that these resources do expose these properties in their outputs.tf files
  st_map = data.terraform_remote_state.infra.outputs.storage_account_ids
  rbac_assignments_st = [
    for region, kv_id in local.st_map : {
      scope                = kv_id
      role_definition_name = "Storage Blob Data Reader"
    }
  ]

  # Make sure that these resources do expose these properties in their outputs.tf files
  db_map = data.terraform_remote_state.infra.outputs.sql_server_ids
  rbac_assignments_db = [
    for region, kv_id in local.db_map : {
      scope                = kv_id
      role_definition_name = "SQL DB Contributor"
    }
  ]

  all_rbac_assignments = concat(
    var.assignments,
    local.rbac_assignments_kv,
    local.rbac_assignments_st,
    local.rbac_assignments_db
  )
}
