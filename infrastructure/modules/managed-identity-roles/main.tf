
module "global_managed_identity" {
  source = "../managed-identity"

  uai_name            = join("-", compact([var.user_identity_prefix, var.uai_name, var.environment]))
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Note: when adding permissions relevant to any definition,
# DO NOT use the "*" action. Instead be specific about the permission(s)
# to use. Doing so ensures we keep control on least privilege access control

resource "azurerm_role_definition" "global_mi_storage_role_definition" {
  name        = join("-", [var.user_identity_prefix, var.environment, "mi-global-storage-role"])
  scope       = data.azurerm_resource_group.target_resource_group.id
  description = "Contains the least required roles for storage access to queues, blobs and tables"

  permissions {
    actions = [
      "Microsoft.Storage/storageAccounts/blobServices/containers/read",
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/add/action",
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/list/action"
    ]

    data_actions = [
      # Storage blob data
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read",
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/write",
      "Microsoft.Storage/storageAccounts/blobServices/generateUserDelegationKey/action",

      # Storage queue data
      "Microsoft.Storage/storageAccounts/queueServices/queues/read",
      "Microsoft.Storage/storageAccounts/queueServices/queues/messages/add/action",
      "Microsoft.Storage/storageAccounts/queueServices/queues/messages/read",
      "Microsoft.Storage/storageAccounts/queueServices/queues/messages/process/action",

      # Storage table data
      "Microsoft.Storage/storageAccounts/tableServices/tables/entities/read",
      "Microsoft.Storage/storageAccounts/tableServices/tables/entities/add/action",
      "Microsoft.Storage/storageAccounts/tableServices/tables/entities/delete/action",
      "Microsoft.Storage/storageAccounts/tableServices/tables/entities/update/action",
    ]
    not_actions       = []
    not_data_actions  = []
  }

  assignable_scopes = [
    data.azurerm_resource_group.target_resource_group.id
  ]
}

resource "azurerm_role_definition" "global_mi_keyvault_role_definition" {
  name        = join("-", [var.user_identity_prefix, var.environment, "mi-global-keyvault-role"])
  scope       = data.azurerm_resource_group.target_resource_group.id
  description = "Contains the least required roles for keyvault access"

  permissions {
    actions = [
      "Microsoft.KeyVault/vaults/read",
    ]
    data_actions = [
      "Microsoft.KeyVault/vaults/secrets/getSecret/action",
      "Microsoft.KeyVault/vaults/secrets/listSecrets/action",
      "Microsoft.KeyVault/vaults/secrets/readMetadata/action",
      "Microsoft.KeyVault/vaults/secrets/set/action"
    ]
    not_actions       = []
    not_data_actions  = []
  }

  assignable_scopes = [
    data.azurerm_resource_group.target_resource_group.id
  ]
}

resource "azurerm_role_definition" "global_mi_sql_role_definition" {
  name        = join("-", [var.user_identity_prefix, var.environment, "mi-global-sql-role"])
  scope       = data.azurerm_resource_group.target_resource_group.id
  description = "Contains the least required roles for SQL data access"

  permissions {
    actions = [
      "Microsoft.Sql/servers/read",
      "Microsoft.Sql/servers/databases/read",
      "Microsoft.Sql/servers/databases/write",
      "Microsoft.Sql/servers/databases/securityAlertPolicies/write",
      "Microsoft.Sql/servers/databases/auditingSettings/write"
    ]
    data_actions = [
    ]
    not_actions       = []
    not_data_actions  = []
  }

  assignable_scopes = [
    data.azurerm_resource_group.target_resource_group.id
  ]
}


