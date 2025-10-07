# postgresql-flexible

## Terraform documentation
For the list of inputs, outputs, resources... check the [terraform module documentation](tfdocs.md).

## Usage

```hcl
module "postgres" {
  source = "../modules/dtos-devops-templates/infrastructure/modules/postgresql-flexible"

  name                = module.shared_config.names.postgres-sql-server
  resource_group_name = azurerm_resource_group.main.name
  location            = local.region

  backup_retention_days           = 7
  geo_redundant_backup_enabled    = true
  postgresql_admin_object_id      = data.azuread_group.postgres_sql_admin_group.object_id
  postgresql_admin_principal_name = local.postgres_sql_admin_group
  postgresql_admin_principal_type = "Group"
  administrator_login             = "admin"
  admin_identities                = [module.db_connect_identity]  # List the managed identies modules to give them admin access

  log_analytics_workspace_id                                = module.log_analytics_workspace_audit.id
  monitor_diagnostic_setting_postgresql_server_enabled_logs = ["PostgreSQLLogs", "PostgreSQLFlexSessions", "PostgreSQLFlexQueryStoreRuntime", "PostgreSQLFlexQueryStoreWaitStats", "PostgreSQLFlexTableStats", "PostgreSQLFlexDatabaseXacts"]
  monitor_diagnostic_setting_postgresql_server_metrics      = ["AllMetrics"]

  sku_name     = "B_Standard_B1ms"
  storage_mb   = 32768
  storage_tier = "P4"

  server_version = "16"
  tenant_id      = data.azurerm_client_config.current.tenant_id

  # Private Endpoint Configuration if enabled
  private_endpoint_properties = {
    private_dns_zone_ids_postgresql      = [data.azurerm_private_dns_zone.postgres.id]
    private_endpoint_enabled             = true
    private_endpoint_subnet_id           = module.postgres_subnet.id
    private_endpoint_resource_group_name = azurerm_resource_group.main.name
    private_service_connection_is_manual = false
  }

  databases = {
    db1 = {
      collation   = "en_US.utf8"
      charset     = "UTF8"
      max_size_gb = 10
      name        = "manage_breast_screening"
    }
  }

  depends_on = [
    module.peering_spoke_hub,
    module.peering_hub_spoke
  ]
}
```

## Alerts

To enable container app alerting:
- Set `enable_alerting = true`.

Example:
```hcl
module "postgres" {
  ...
  enable_alerting                 = true
  action_group_id                 = <action_group_id>
  alert_memory_threshold          = 80 (already defaults to this)
  alert_cpu_threshold             = 80 (already defaults to this)
  alert_storage_threshold         =  (already defaults to this)
}
```
