
# Note: when adding permissions relevant to any definition,
# Try to not use the "*" action if possible. Instead be specific
# about the permission(s) to use. Doing so ensures we keep control on
# least privilege access control

resource "azurerm_role_definition" "global_mi_storage_role_definition" {
  name        = lower(join("-", ["mi-global-role-storage", var.environment]))
  scope       = data.azurerm_resource_group.target_resource_group.id
  description = "Contains the least required roles for storage access to queues, blobs and tables"

  # Reference: https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/storage#storage-queue-data-contributor
  permissions {
    actions = [

      "Microsoft.Storage/storageAccounts/listkeys/action",
      "Microsoft.Storage/storageAccounts/regeneratekey/action",

      "Microsoft.Storage/storageAccounts/blobServices/containers/delete",
      "Microsoft.Storage/storageAccounts/blobServices/containers/read",
      "Microsoft.Storage/storageAccounts/blobServices/containers/write",
      "Microsoft.Storage/storageAccounts/blobServices/generateUserDelegationKey/action",

      "Microsoft.Storage/storageAccounts/queueServices/queues/delete",
      "Microsoft.Storage/storageAccounts/queueServices/queues/read",
      "Microsoft.Storage/storageAccounts/queueServices/queues/write",

      "Microsoft.Storage/storageAccounts/tableServices/tables/read",
      "Microsoft.Storage/storageAccounts/tableServices/tables/write",
      "Microsoft.Storage/storageAccounts/tableServices/tables/delete",
    ]

    data_actions = [
      # Blob data
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/delete",
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read",
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/write",
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/move/action",
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/add/action",

      # Queue data
      "Microsoft.Storage/storageAccounts/queueServices/queues/messages/delete",
      "Microsoft.Storage/storageAccounts/queueServices/queues/messages/read",
      "Microsoft.Storage/storageAccounts/queueServices/queues/messages/write",
      "Microsoft.Storage/storageAccounts/queueServices/queues/messages/process/action",
      "Microsoft.Storage/storageAccounts/queueServices/queues/messages/add/action",

      # Table data
      "Microsoft.Storage/storageAccounts/tableServices/tables/entities/read",
      "Microsoft.Storage/storageAccounts/tableServices/tables/entities/write",
      "Microsoft.Storage/storageAccounts/tableServices/tables/entities/delete",
      "Microsoft.Storage/storageAccounts/tableServices/tables/entities/add/action",
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
  name        = lower(join("-", ["mi-global-role-keyvault", var.environment]))
  scope       = data.azurerm_resource_group.target_resource_group.id
  description = "Contains the least required roles for keyvault access"

  # Reference: https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/security#key-vault-reader
  permissions {
    actions = [
      "Microsoft.KeyVault/vaults/read",
    ]
    data_actions = [
      # Certificate USer
      "Microsoft.KeyVault/vaults/certificates/read",
      "Microsoft.KeyVault/vaults/secrets/getSecret/action",
      "Microsoft.KeyVault/vaults/secrets/readMetadata/action",
      "Microsoft.KeyVault/vaults/keys/read",

      # Crypto User
      "Microsoft.KeyVault/vaults/keys/read",
      "Microsoft.KeyVault/vaults/keys/update/action",
      "Microsoft.KeyVault/vaults/keys/backup/action",
      "Microsoft.KeyVault/vaults/keys/encrypt/action",
      "Microsoft.KeyVault/vaults/keys/decrypt/action",
      "Microsoft.KeyVault/vaults/keys/wrap/action",
      "Microsoft.KeyVault/vaults/keys/unwrap/action",
      "Microsoft.KeyVault/vaults/keys/sign/action",
      "Microsoft.KeyVault/vaults/keys/verify/action",

      # Secrets User
      "Microsoft.KeyVault/vaults/secrets/getSecret/action",
      "Microsoft.KeyVault/vaults/secrets/readMetadata/action",

    ]
    not_actions       = []
    not_data_actions  = []
  }

  assignable_scopes = [
    data.azurerm_resource_group.target_resource_group.id
  ]
}

resource "azurerm_role_definition" "global_mi_sql_role_definition" {
  name        = lower(join("-", ["mi-global-role-sql", var.environment]))
  scope       = data.azurerm_resource_group.target_resource_group.id
  description = "Contains the least required roles for SQL data access"

  # Reference: https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/databases
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


