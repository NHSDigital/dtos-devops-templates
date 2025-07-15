module "global_storage_role_rw" {
  source = "../role-definition"

  name        = lower(join("-", ["mi-global-role-storage", var.environment]))
  environment = var.environment
  scope       = var.role_scope_id
  assignable_scopes = var.assignable_scopes
  description = "Contains the least required roles for storage access to queues, blobs and tables"

  permissions = {
    actions = concat(
      local.action_storage_rw_accounts,
      local.action_storage_rw_container,
      local.action_storage_rw_queue,
      local.action_storage_rw_table
    )

    data_actions = concat(
      local.data_storage_rw_blob,
      local.data_storage_rw_queue,
      local.data_storage_rw_table
    )
  }
}

module "global_keyvault_role_rw" {
  source = "../role-definition"

  name        = lower(join("-", ["mi-global-role-keyvault", var.environment]))
  environment = var.environment
  scope       = var.role_scope_id
  description = "Contains the least required roles for keyvault access"
  assignable_scopes = var.assignable_scopes

  permissions = {
    actions = concat(
      local.action_keyvault_rw
    )

    data_actions = concat(
      local.data_keyvault_rw_cert_user,
      local.data_keyvault_rw_crypto_user,
      local.data_keyvault_rw_secrets_user
    )
  }
}

module "global_sql_role_rw" {
  source = "../role-definition"

  name        = lower(join("-", ["mi-global-role-sql", var.environment]))
  environment = var.environment
  scope       = var.role_scope_id
  description = "Contains the least required roles for SQL data access"
  assignable_scopes = var.assignable_scopes

  permissions = {
    actions = concat(
      local.action_sql_rw,
    )
  }
}

module "global_event_grid_role_rw" {
  source = "../role-definition"

  name        = lower(join("-", ["mi-global-role-grid", var.environment]))
  environment = var.environment
  scope       = var.role_scope_id
  description = "Contains the least required roles for Event Grid data access"
  assignable_scopes = var.assignable_scopes

  permissions = {
    actions = concat(
      local.action_grid_rw
    )
    data_actions = concat(
      local.data_grid_rw_sender
    )
  }
}

module "global_service_bus_role_rw" {
  source = "../role-definition"

  name        = lower(join("-", ["mi-global-role-bus", var.environment]))
  environment = var.environment
  scope       = var.role_scope_id
  description = "Contains the least required roles for Servicebus sender and receiver access"
  assignable_scopes = var.assignable_scopes

  permissions = {
    actions = concat(
      local.action_bus_rw
    ),
    data_actions = concat(
      local.data_bus_rw_sender,
      local.data_bus_rw_receiver
    )
  }
}

