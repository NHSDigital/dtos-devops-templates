# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_ad_auth_only"></a> [ad\_auth\_only](#input\_ad\_auth\_only)

Description: Specifies whether only AD Users and administrators can be used to login, or also local database users.

Type: `bool`

### <a name="input_kv_id"></a> [kv\_id](#input\_kv\_id)

Description: Name of the Key Vault in which the admin credentials are put

Type: `string`

### <a name="input_location"></a> [location](#input\_location)

Description: The location/region where the SQL Server is created.

Type: `string`

### <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id)

Description: id of the log analytics workspace to send resource logging to via diagnostic settings

Type: `string`

### <a name="input_monitor_diagnostic_setting_database_enabled_logs"></a> [monitor\_diagnostic\_setting\_database\_enabled\_logs](#input\_monitor\_diagnostic\_setting\_database\_enabled\_logs)

Description: Controls what logs will be enabled for the database

Type: `list(string)`

### <a name="input_monitor_diagnostic_setting_database_metrics"></a> [monitor\_diagnostic\_setting\_database\_metrics](#input\_monitor\_diagnostic\_setting\_database\_metrics)

Description: Controls what metrics will be enabled for the database

Type: `list(string)`

### <a name="input_monitor_diagnostic_setting_sql_server_enabled_logs"></a> [monitor\_diagnostic\_setting\_sql\_server\_enabled\_logs](#input\_monitor\_diagnostic\_setting\_sql\_server\_enabled\_logs)

Description: Controls what logs will be enabled for the sql server

Type: `list(string)`

### <a name="input_monitor_diagnostic_setting_sql_server_metrics"></a> [monitor\_diagnostic\_setting\_sql\_server\_metrics](#input\_monitor\_diagnostic\_setting\_sql\_server\_metrics)

Description: Controls what metrics will be enabled for the sql server

Type: `list(string)`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the Azure MSSQL Server.

Type: `string`

### <a name="input_primary_blob_endpoint_name"></a> [primary\_blob\_endpoint\_name](#input\_primary\_blob\_endpoint\_name)

Description: Name of storage account primary endpoint

Type: `string`

### <a name="input_private_endpoint_properties"></a> [private\_endpoint\_properties](#input\_private\_endpoint\_properties)

Description: Consolidated properties for the Function App Private Endpoint.

Type:

```hcl
object({
    private_dns_zone_ids_sql             = optional(list(string), [])
    private_endpoint_enabled             = optional(bool, false)
    private_endpoint_subnet_id           = optional(string, "")
    private_endpoint_resource_group_name = optional(string, "")
    private_service_connection_is_manual = optional(bool, false)
  })
```

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which to create the SQL Server. Changing this forces a new resource to be created.

Type: `string`

### <a name="input_sql_admin_group_name"></a> [sql\_admin\_group\_name](#input\_sql\_admin\_group\_name)

Description: Name of the Entra ID group with permissions to manage the SQL Server

Type: `string`

### <a name="input_sql_admin_object_id"></a> [sql\_admin\_object\_id](#input\_sql\_admin\_object\_id)

Description: The object ID from EntraID for SQL Server Admin.

Type: `string`

### <a name="input_sql_server_alert_policy_state"></a> [sql\_server\_alert\_policy\_state](#input\_sql\_server\_alert\_policy\_state)

Description: Controls the sql server alert policy state

Type: `string`

### <a name="input_sql_uai_name"></a> [sql\_uai\_name](#input\_sql\_uai\_name)

Description: Name of the User Assigned Identity for SQL Server

Type: `string`

### <a name="input_storage_account_id"></a> [storage\_account\_id](#input\_storage\_account\_id)

Description: Id of the storage account to send audit logging to

Type: `string`

### <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name)

Description: Name of the storage account to send audit logging to (unused)

Type: `string`

### <a name="input_storage_container_id"></a> [storage\_container\_id](#input\_storage\_container\_id)

Description: Storage container id to save audit data to

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_auditing_policy_retention_in_days"></a> [auditing\_policy\_retention\_in\_days](#input\_auditing\_policy\_retention\_in\_days)

Description: number of days for audit log policies

Type: `number`

Default: `6`

### <a name="input_collation"></a> [collation](#input\_collation)

Description: Specifies the collation of the database. Changing this forces a new resource to be created.

Type: `string`

Default: `"SQL_Latin1_General_CP1_CI_AS"`

### <a name="input_database_extended_auditing_policy_enabled"></a> [database\_extended\_auditing\_policy\_enabled](#input\_database\_extended\_auditing\_policy\_enabled)

Description: Enable extended auditing policy for SQL database

Type: `bool`

Default: `true`

### <a name="input_db_name_suffix"></a> [db\_name\_suffix](#input\_db\_name\_suffix)

Description: The name of the MS SQL Database. Changing this forces a new resource to be created.

Type: `string`

Default: `"baseline"`

### <a name="input_firewall_rules"></a> [firewall\_rules](#input\_firewall\_rules)

Description: If the FW rule enabling Azure Services Passthrough should be deployed.

Type:

```hcl
map(object({
    start_ip_address = optional(string, "")
    end_ip_address   = optional(string, "")
  }))
```

Default: `{}`

### <a name="input_licence_type"></a> [licence\_type](#input\_licence\_type)

Description:  Specifies the license type applied to this database. Possible values are LicenseIncluded and BasePrice

Type: `string`

Default: `"LicenseIncluded"`

### <a name="input_log_monitoring_enabled"></a> [log\_monitoring\_enabled](#input\_log\_monitoring\_enabled)

Description: Default value for Log Monitoring Enabled

Type: `bool`

Default: `true`

### <a name="input_long_term_retention_policy"></a> [long\_term\_retention\_policy](#input\_long\_term\_retention\_policy)

Description: The long term retention policy for the database

Type:

```hcl
object({
    weekly_retention  = optional(string, null)
    monthly_retention = optional(string, null)
    yearly_retention  = optional(string, null)
    week_of_year      = optional(number, null)
  })
```

Default: `{}`

### <a name="input_max_gb"></a> [max\_gb](#input\_max\_gb)

Description: The max size of the database in gigabytes

Type: `number`

Default: `5`

### <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled)

Description: Specifies whether or not public network access is allowed for this server.

Type: `bool`

Default: `false`

### <a name="input_read_scale"></a> [read\_scale](#input\_read\_scale)

Description: If enabled, connections that have application intent set to readonly in their connection string may be routed to a readonly secondary replica. This property is only settable for Premium and Business Critical databases.

Type: `bool`

Default: `false`

### <a name="input_security_alert_policy_retention_days"></a> [security\_alert\_policy\_retention\_days](#input\_security\_alert\_policy\_retention\_days)

Description: number of days for security alert log policies

Type: `number`

Default: `6`

### <a name="input_short_term_retention_policy"></a> [short\_term\_retention\_policy](#input\_short\_term\_retention\_policy)

Description: The short term retention policy for the database (in days)

Type: `number`

Default: `null`

### <a name="input_sku"></a> [sku](#input\_sku)

Description: Specifies the name of the SKU used by the database. For example, GP\_S\_Gen5\_2,HS\_Gen4\_1,BC\_Gen5\_2, ElasticPool, Basic,S0, P2 ,DW100c, DS100. Changing this from the HyperScale service tier to another service tier will create a new resource.

Type: `string`

Default: `"50"`

### <a name="input_sqlversion"></a> [sqlversion](#input\_sqlversion)

Description: Version of SQL to be created

Type: `string`

Default: `"12.0"`

### <a name="input_storage_account_type"></a> [storage\_account\_type](#input\_storage\_account\_type)

Description: storage account type: Geo, GeoZone, Local and Zone

Type: `string`

Default: `"Local"`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: Resource tags to be applied throughout the deployment.

Type: `map(string)`

Default: `{}`

### <a name="input_tlsver"></a> [tlsver](#input\_tlsver)

Description:  The Minimum TLS Version for all SQL Database and SQL Data Warehouse databases associated with the server

Type: `number`

Default: `1.2`

### <a name="input_vulnerability_assessment_enabled"></a> [vulnerability\_assessment\_enabled](#input\_vulnerability\_assessment\_enabled)

Description: to enable extended auditing policy for server or database

Type: `bool`

Default: `false`

### <a name="input_zone_redundant"></a> [zone\_redundant](#input\_zone\_redundant)

Description: To disable zone redundancy.

Type: `bool`

Default: `false`
## Modules

The following Modules are called:

### <a name="module_azurerm_monitor_diagnostic_setting_db"></a> [azurerm\_monitor\_diagnostic\_setting\_db](#module\_azurerm\_monitor\_diagnostic\_setting\_db)

Source: ../diagnostic-settings

Version:

### <a name="module_diagnostic_setting_sql_server"></a> [diagnostic\_setting\_sql\_server](#module\_diagnostic\_setting\_sql\_server)

Source: ../diagnostic-settings

Version:

### <a name="module_private_endpoint_sql_server"></a> [private\_endpoint\_sql\_server](#module\_private\_endpoint\_sql\_server)

Source: ../private-endpoint

Version:

### <a name="module_rbac_assignments"></a> [rbac\_assignments](#module\_rbac\_assignments)

Source: ../rbac-assignment

Version:
## Outputs

The following outputs are exported:

### <a name="output_sql_server_id"></a> [sql\_server\_id](#output\_sql\_server\_id)

Description: The ID of the SQL Server.
## Resources

The following resources are used by this module:

- [azurerm_mssql_database.defaultdb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database) (resource)
- [azurerm_mssql_database_extended_auditing_policy.database_auditing_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database_extended_auditing_policy) (resource)
- [azurerm_mssql_firewall_rule.firewall_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_firewall_rule) (resource)
- [azurerm_mssql_server.azure_sql_server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server) (resource)
- [azurerm_mssql_server_extended_auditing_policy.azure_sql_server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server_extended_auditing_policy) (resource)
- [azurerm_mssql_server_security_alert_policy.sql_server_alert_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server_security_alert_policy) (resource)
- [azurerm_mssql_server_vulnerability_assessment.sql_server_vulnerability_assessment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server_vulnerability_assessment) (resource)
