# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_backup_retention_days"></a> [backup\_retention\_days](#input\_backup\_retention\_days)

Description: The number of days to retain backups for the PostgreSQL Flexible Server.

Type: `number`

### <a name="input_databases"></a> [databases](#input\_databases)

Description: A map of databases to create on the PostgreSQL Flexible Server.

Type:

```hcl
map(object({
    collation   = string
    charset     = string
    max_size_gb = number
    name        = string
  }))
```

### <a name="input_geo_redundant_backup_enabled"></a> [geo\_redundant\_backup\_enabled](#input\_geo\_redundant\_backup\_enabled)

Description: Whether geo-redundant backup is enabled for the PostgreSQL Flexible Server.

Type: `bool`

### <a name="input_location"></a> [location](#input\_location)

Description: The location/region where the PostgreSQL Flexible Server is created.

Type: `string`

### <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id)

Description: id of the log analytics workspace to send resource logging to via diagnostic settings

Type: `string`

### <a name="input_monitor_diagnostic_setting_postgresql_server_enabled_logs"></a> [monitor\_diagnostic\_setting\_postgresql\_server\_enabled\_logs](#input\_monitor\_diagnostic\_setting\_postgresql\_server\_enabled\_logs)

Description: Controls what logs will be enabled for the sql server

Type: `list(string)`

### <a name="input_monitor_diagnostic_setting_postgresql_server_metrics"></a> [monitor\_diagnostic\_setting\_postgresql\_server\_metrics](#input\_monitor\_diagnostic\_setting\_postgresql\_server\_metrics)

Description: Controls what metrics will be enabled for the sql server

Type: `list(string)`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the PostgreSQL Flexible Server.

Type: `string`

### <a name="input_postgresql_admin_object_id"></a> [postgresql\_admin\_object\_id](#input\_postgresql\_admin\_object\_id)

Description: The object ID of the PostgreSQL Active Directory administrator.

Type: `string`

### <a name="input_postgresql_admin_principal_name"></a> [postgresql\_admin\_principal\_name](#input\_postgresql\_admin\_principal\_name)

Description: The principal name of the PostgreSQL Active Directory administrator.

Type: `string`

### <a name="input_postgresql_admin_principal_type"></a> [postgresql\_admin\_principal\_type](#input\_postgresql\_admin\_principal\_type)

Description: The principal type of the PostgreSQL Active Directory administrator.

Type: `string`

### <a name="input_private_endpoint_properties"></a> [private\_endpoint\_properties](#input\_private\_endpoint\_properties)

Description: Consolidated properties for the PostgreSql Private Endpoint.

Type:

```hcl
object({
    private_dns_zone_ids_postgresql      = optional(list(string), [])
    private_endpoint_enabled             = optional(bool, false)
    private_endpoint_subnet_id           = optional(string, "")
    private_endpoint_resource_group_name = optional(string, "")
    private_service_connection_is_manual = optional(bool, false)
  })
```

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which to create the PostgreSQL Flexible Server.

Type: `string`

### <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name)

Description: The SKU name for the PostgreSQL Flexible Server.

Type: `string`

### <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id)

Description: The tenant ID for the Azure Active Directory.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_admin_identities"></a> [admin\_identities](#input\_admin\_identities)

Description: List of managed identities modules with admin access to the postgres server. The managed identity must have the Directory.Read.All permission.

Type: `list(any)`

Default: `[]`

### <a name="input_administrator_login"></a> [administrator\_login](#input\_administrator\_login)

Description: n/a

Type: `string`

Default: `null`

### <a name="input_key_vault_admin_pwd_secret_name"></a> [key\_vault\_admin\_pwd\_secret\_name](#input\_key\_vault\_admin\_pwd\_secret\_name)

Description: Key Vault secret name in which to store the Admin password, if one is created.

Type: `string`

Default: `null`

### <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id)

Description: ID of the Key Vault in which to store the Admin password, if one is created.

Type: `string`

Default: `null`

### <a name="input_password_auth_enabled"></a> [password\_auth\_enabled](#input\_password\_auth\_enabled)

Description: n/a

Type: `bool`

Default: `false`

### <a name="input_postgresql_configurations"></a> [postgresql\_configurations](#input\_postgresql\_configurations)

Description: A map of PostgreSQL configurations to apply to the PostgreSQL Flexible Server.

Type: `map(string)`

Default: `{}`

### <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled)

Description: Whether public network access is enabled for the PostgreSQL Flexible Server.

Type: `bool`

Default: `false`

### <a name="input_server_version"></a> [server\_version](#input\_server\_version)

Description: The version of the PostgreSQL server.

Type: `string`

Default: `"16"`

### <a name="input_storage_mb"></a> [storage\_mb](#input\_storage\_mb)

Description: The storage size in MB for the PostgreSQL Flexible Server.

Type: `number`

Default: `32768`

### <a name="input_storage_tier"></a> [storage\_tier](#input\_storage\_tier)

Description: The storage tier for the PostgreSQL Flexible Server.

Type: `string`

Default: `"P4"`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: A map of tags to assign to the PostgreSQL Flexible Server.

Type: `map(string)`

Default: `{}`

### <a name="input_zone"></a> [zone](#input\_zone)

Description: The availability zone for the PostgreSQL Flexible Server. Azure will automatically assign an Availability Zone if one is not specified.

Type: `string`

Default: `null`
## Modules

The following Modules are called:

### <a name="module_diagnostic_setting_postgresql_server"></a> [diagnostic\_setting\_postgresql\_server](#module\_diagnostic\_setting\_postgresql\_server)

Source: ../diagnostic-settings

Version:

### <a name="module_private_endpoint_postgresql_flexible_server"></a> [private\_endpoint\_postgresql\_flexible\_server](#module\_private\_endpoint\_postgresql\_flexible\_server)

Source: ../private-endpoint

Version:
## Outputs

The following outputs are exported:

### <a name="output_database_names"></a> [database\_names](#output\_database\_names)

Description: n/a

### <a name="output_db_admin_pwd_keyvault_secret"></a> [db\_admin\_pwd\_keyvault\_secret](#output\_db\_admin\_pwd\_keyvault\_secret)

Description: n/a

### <a name="output_host"></a> [host](#output\_host)

Description: n/a
## Resources

The following resources are used by this module:

- [azurerm_key_vault_secret.db_admin_pwd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) (resource)
- [azurerm_postgresql_flexible_server.postgresql_flexible_server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server) (resource)
- [azurerm_postgresql_flexible_server_active_directory_administrator.admin_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_active_directory_administrator) (resource)
- [azurerm_postgresql_flexible_server_active_directory_administrator.postgresql_admin](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_active_directory_administrator) (resource)
- [azurerm_postgresql_flexible_server_configuration.postgresql_flexible_config](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_configuration) (resource)
- [azurerm_postgresql_flexible_server_database.postgresql_flexible_db](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_database) (resource)
- [random_password.admin_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) (resource)
