
# Note: when adding permissions relevant to any definition,
# Try to not use the "*" action if possible. Instead be specific
# about the permission(s) to use. Doing so ensures we keep control on
# least privilege access control

locals {
  # https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/containers#acrpull
  action_acr_rw = [
    "Microsoft.ContainerRegistry/registries/pull/read"
  ]

  # https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/storage#storage-queue-data-contributor
  action_storage_rw_accounts = [
    "Microsoft.Storage/storageAccounts/listkeys/action",
    "Microsoft.Storage/storageAccounts/regeneratekey/action",
  ]

  action_storage_rw_container = [
    "Microsoft.Storage/storageAccounts/blobServices/containers/delete",
    "Microsoft.Storage/storageAccounts/blobServices/containers/read",
    "Microsoft.Storage/storageAccounts/blobServices/containers/write",
    "Microsoft.Storage/storageAccounts/blobServices/generateUserDelegationKey/action",
  ]

  action_storage_rw_queue = [
    "Microsoft.Storage/storageAccounts/queueServices/queues/delete",
    "Microsoft.Storage/storageAccounts/queueServices/queues/read",
    "Microsoft.Storage/storageAccounts/queueServices/queues/write",
  ]

  action_storage_rw_table = [
    "Microsoft.Storage/storageAccounts/tableServices/tables/read",
    "Microsoft.Storage/storageAccounts/tableServices/tables/write",
    "Microsoft.Storage/storageAccounts/tableServices/tables/delete",
  ]

  data_storage_rw_blob = [
    "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/delete",
    "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read",
    "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/write",
    "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/move/action",
    "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/add/action",
  ]

  data_storage_rw_queue = [
    "Microsoft.Storage/storageAccounts/queueServices/queues/messages/delete",
    "Microsoft.Storage/storageAccounts/queueServices/queues/messages/read",
    "Microsoft.Storage/storageAccounts/queueServices/queues/messages/write",
    "Microsoft.Storage/storageAccounts/queueServices/queues/messages/process/action",
    "Microsoft.Storage/storageAccounts/queueServices/queues/messages/add/action",
  ]

  data_storage_rw_table = [
    "Microsoft.Storage/storageAccounts/tableServices/tables/entities/read",
    "Microsoft.Storage/storageAccounts/tableServices/tables/entities/write",
    "Microsoft.Storage/storageAccounts/tableServices/tables/entities/delete",
    "Microsoft.Storage/storageAccounts/tableServices/tables/entities/add/action",
    "Microsoft.Storage/storageAccounts/tableServices/tables/entities/update/action",
  ]

  # https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/security#key-vault-reader
  action_keyvault_rw = [
    "Microsoft.KeyVault/vaults/read",
  ]

  data_keyvault_rw_cert_user = [
    "Microsoft.KeyVault/vaults/certificates/read",
    "Microsoft.KeyVault/vaults/secrets/getSecret/action",
    "Microsoft.KeyVault/vaults/secrets/readMetadata/action",
    "Microsoft.KeyVault/vaults/keys/read",
  ]

  data_keyvault_rw_crypto_user = [
    "Microsoft.KeyVault/vaults/keys/read",
    "Microsoft.KeyVault/vaults/keys/update/action",
    "Microsoft.KeyVault/vaults/keys/backup/action",
    "Microsoft.KeyVault/vaults/keys/encrypt/action",
    "Microsoft.KeyVault/vaults/keys/decrypt/action",
    "Microsoft.KeyVault/vaults/keys/wrap/action",
    "Microsoft.KeyVault/vaults/keys/unwrap/action",
    "Microsoft.KeyVault/vaults/keys/sign/action",
    "Microsoft.KeyVault/vaults/keys/verify/action",
  ]

  data_keyvault_rw_secrets_user = [
    "Microsoft.KeyVault/vaults/secrets/getSecret/action",
    "Microsoft.KeyVault/vaults/secrets/readMetadata/action",
  ]

  # https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/databases
  action_sql_rw = [
    "Microsoft.Sql/servers/read",
    "Microsoft.Sql/servers/databases/read",
    "Microsoft.Sql/servers/databases/write",
    "Microsoft.Sql/servers/databases/securityAlertPolicies/write",
    "Microsoft.Sql/servers/databases/auditingSettings/write"
  ]

  # https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/integration
  action_bus_rw = [
    # Sender & Receiver
    "Microsoft.ServiceBus/*/queues/read",
    "Microsoft.ServiceBus/*/topics/read",
    "Microsoft.ServiceBus/*/topics/subscriptions/read"
  ]

  data_bus_rw_sender = [
    "Microsoft.ServiceBus/*/send/action"
  ]

  data_bus_rw_receiver = [
    "Microsoft.ServiceBus/*/receive/action"
  ]

  # https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/integration#eventgrid-data-sender
  action_grid_rw = [
    # Sender
    "Microsoft.Authorization/*/read",
    "Microsoft.EventGrid/topics/read",
    "Microsoft.EventGrid/domains/read",
    "Microsoft.EventGrid/partnerNamespaces/read",
    "Microsoft.Resources/subscriptions/resourceGroups/read",
    "Microsoft.EventGrid/namespaces/read",

    # Receiver
    "Microsoft.EventGrid/eventSubscriptions/read",
    "Microsoft.EventGrid/topicTypes/eventSubscriptions/read",
    "Microsoft.EventGrid/locations/eventSubscriptions/read",
    "Microsoft.EventGrid/locations/topicTypes/eventSubscriptions/read",
    "Microsoft.Resources/subscriptions/resourceGroups/read"
  ]

  data_grid_rw_sender = [
    "Microsoft.EventGrid/events/send/action"
  ]
}
