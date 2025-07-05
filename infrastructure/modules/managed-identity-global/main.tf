
module "global_uami" {
  source = "../managed-identity"

  uai_name            = join("-", compact([var.identity_prefix, var.environment]))
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_role_definition" "global_uami_storage_role_definition" {
  name        = "${var.identity_prefix}-${var.environment}-uami-global-storage-role"
  scope       = data.azurerm_resource_group.target.id
  description = "Contains the least required roles for storage access to queues, blobs and tables"

  permissions {
    actions = [
      # Storage blob control-plane
      "Microsoft.Storage/storageAccounts/blobServices/containers/read",
      "Microsoft.Storage/storageAccounts/blobServices/generateUserDelegationKey/action"
    ]
    data_actions = [
      # Storage blob data
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read",

      # Storage queue data
      "Microsoft.Storage/storageAccounts/queueServices/queues/messages/add/action",
      "Microsoft.Storage/storageAccounts/queueServices/queues/messages/read",
      "Microsoft.Storage/storageAccounts/queueServices/queues/messages/process/action",

      # Storage table data
      "Microsoft.Storage/storageAccounts/tableServices/tables/entities/read",
      "Microsoft.Storage/storageAccounts/tableServices/tables/entities/add/action",
      "Microsoft.Storage/storageAccounts/tableServices/tables/entities/update/action",
      "Microsoft.Storage/storageAccounts/tableServices/tables/entities/delete/action"
    ]
    not_actions       = []
    not_data_actions  = []
  }

  assignable_scopes = [
    data.azurerm_resource_group.target.id
  ]
}

resource "azurerm_role_definition" "global_uami_keyvault_role_definition" {
  name        = "${var.identity_prefix}-${var.environment}-uami-global-keyvault-role"
  scope       = data.azurerm_resource_group.target.id
  description = "Contains the least required roles for keyvault access"

  permissions {
    actions = [
    ]
    data_actions = [
      # Key Vault secrets
      "Microsoft.KeyVault/vaults/secrets/getSecret/action",
      "Microsoft.KeyVault/vaults/secrets/readMetadata/action",
    ]
    not_actions       = []
    not_data_actions  = []
  }

  assignable_scopes = [
    data.azurerm_resource_group.target.id
  ]
}

resource "azurerm_role_definition" "global_uami_sql_role_definition" {
  name        = "${var.identity_prefix}-${var.environment}-uami-global-sql-role"
  scope       = data.azurerm_resource_group.target.id
  description = "Contains the least required roles for SQL data access"

  permissions {
    actions = [
      # SQL control-plane
      "Microsoft.Sql/servers/*",
      "Microsoft.Authorization/*/read",
    ]
    data_actions = [
    ]
    not_actions       = []
    not_data_actions  = []
  }

  assignable_scopes = [
    data.azurerm_resource_group.target.id
  ]
}


