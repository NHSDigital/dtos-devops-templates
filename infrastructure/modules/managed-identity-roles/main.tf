module "global_role_definition_rw" {
  source = "../role-definition"

  name              = var.role_name
  environment       = var.environment
  scope             = var.role_scope_id
  assignable_scopes = var.assignable_scopes
  description       = "Contains the least required roles for storage access to queues, blobs and tables"

  permissions = {
    actions = concat(
      # Storage
      local.action_storage_rw_accounts,
      local.action_storage_rw_container,
      local.action_storage_rw_queue,
      local.action_storage_rw_table,

      # Key vault
      local.action_keyvault_rw,

      # sql
      local.action_sql_rw,

      # event grid
      local.action_grid_rw,

      # service bus
      local.action_bus_rw
    )

    data_actions = concat(
      # Storage
      local.data_storage_rw_blob,
      local.data_storage_rw_queue,
      local.data_storage_rw_table,

      # key vault
      local.data_keyvault_rw_cert_user,
      local.data_keyvault_rw_crypto_user,
      local.data_keyvault_rw_secrets_user,

      # event grid
      local.data_grid_rw_sender,

      # service bus
      local.data_bus_rw_sender,
      local.data_bus_rw_receiver
    )
  }
}
