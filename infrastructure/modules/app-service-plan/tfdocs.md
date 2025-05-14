# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description: The location/region where the App Service Plan is created.

Type: `string`

### <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id)

Description: id of the log analytics workspace to send resource logging to via diagnostic settings

Type: `string`

### <a name="input_monitor_diagnostic_setting_appserviceplan_metrics"></a> [monitor\_diagnostic\_setting\_appserviceplan\_metrics](#input\_monitor\_diagnostic\_setting\_appserviceplan\_metrics)

Description: Controls what metrics will be enabled for the appserviceplan

Type: `list(string)`

### <a name="input_name"></a> [name](#input\_name)

Description: Name of the App Service Plan.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which to create the App Service Plan. Changing this forces a new resource to be created.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_capacity_def"></a> [capacity\_def](#input\_capacity\_def)

Description: n/a

Type: `string`

Default: `"1"`

### <a name="input_capacity_max"></a> [capacity\_max](#input\_capacity\_max)

Description: n/a

Type: `string`

Default: `"5"`

### <a name="input_capacity_min"></a> [capacity\_min](#input\_capacity\_min)

Description: n/a

Type: `string`

Default: `"1"`

### <a name="input_dec_operator"></a> [dec\_operator](#input\_dec\_operator)

Description: n/a

Type: `string`

Default: `"LessThan"`

### <a name="input_dec_scale_cooldown"></a> [dec\_scale\_cooldown](#input\_dec\_scale\_cooldown)

Description: n/a

Type: `string`

Default: `"PT5M"`

### <a name="input_dec_scale_direction"></a> [dec\_scale\_direction](#input\_dec\_scale\_direction)

Description: n/a

Type: `string`

Default: `"Decrease"`

### <a name="input_dec_scale_type"></a> [dec\_scale\_type](#input\_dec\_scale\_type)

Description: n/a

Type: `string`

Default: `"ChangeCount"`

### <a name="input_dec_scale_value"></a> [dec\_scale\_value](#input\_dec\_scale\_value)

Description: n/a

Type: `string`

Default: `"1"`

### <a name="input_dec_threshold"></a> [dec\_threshold](#input\_dec\_threshold)

Description: n/a

Type: `number`

Default: `25`

### <a name="input_inc_operator"></a> [inc\_operator](#input\_inc\_operator)

Description: n/a

Type: `string`

Default: `"GreaterThan"`

### <a name="input_inc_scale_cooldown"></a> [inc\_scale\_cooldown](#input\_inc\_scale\_cooldown)

Description: n/a

Type: `string`

Default: `"PT5M"`

### <a name="input_inc_scale_direction"></a> [inc\_scale\_direction](#input\_inc\_scale\_direction)

Description: n/a

Type: `string`

Default: `"Increase"`

### <a name="input_inc_scale_type"></a> [inc\_scale\_type](#input\_inc\_scale\_type)

Description: n/a

Type: `string`

Default: `"ChangeCount"`

### <a name="input_inc_scale_value"></a> [inc\_scale\_value](#input\_inc\_scale\_value)

Description: n/a

Type: `string`

Default: `"1"`

### <a name="input_inc_threshold"></a> [inc\_threshold](#input\_inc\_threshold)

Description: n/a

Type: `number`

Default: `70`

### <a name="input_metric"></a> [metric](#input\_metric)

Description: n/a

Type: `string`

Default: `"MemoryPercentage"`

### <a name="input_os_type"></a> [os\_type](#input\_os\_type)

Description: OS type for deployed App Service Plan.

Type: `string`

Default: `"Windows"`

### <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name)

Description: SKU name for deployed App Service Plan.

Type: `string`

Default: `"B1"`

### <a name="input_statistic"></a> [statistic](#input\_statistic)

Description: n/a

Type: `string`

Default: `"Average"`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: Resource tags to be applied throughout the deployment.

Type: `map(string)`

Default: `{}`

### <a name="input_time_aggregation"></a> [time\_aggregation](#input\_time\_aggregation)

Description: n/a

Type: `string`

Default: `"Average"`

### <a name="input_time_grain"></a> [time\_grain](#input\_time\_grain)

Description: n/a

Type: `string`

Default: `"PT1M"`

### <a name="input_time_window"></a> [time\_window](#input\_time\_window)

Description: n/a

Type: `string`

Default: `"PT10M"`

### <a name="input_vnet_integration_enabled"></a> [vnet\_integration\_enabled](#input\_vnet\_integration\_enabled)

Description: Indicates whether the App Service Plan is integrated with a VNET.

Type: `bool`

Default: `false`

### <a name="input_vnet_integration_subnet_id"></a> [vnet\_integration\_subnet\_id](#input\_vnet\_integration\_subnet\_id)

Description: The ID of the subnet to integrate with.

Type: `string`

Default: `""`

### <a name="input_wildcard_ssl_cert_key_vault_id"></a> [wildcard\_ssl\_cert\_key\_vault\_id](#input\_wildcard\_ssl\_cert\_key\_vault\_id)

Description: Wildcard SSL certificate Key Vault id, needed if the Key Vault is in a different subscription.

Type: `string`

Default: `null`

### <a name="input_wildcard_ssl_cert_name"></a> [wildcard\_ssl\_cert\_name](#input\_wildcard\_ssl\_cert\_name)

Description: Wildcard SSL certificate name as it will appear in the App Service binding, for Custom Domain binding.

Type: `string`

Default: `null`

### <a name="input_wildcard_ssl_cert_pfx_blob_key_vault_secret_name"></a> [wildcard\_ssl\_cert\_pfx\_blob\_key\_vault\_secret\_name](#input\_wildcard\_ssl\_cert\_pfx\_blob\_key\_vault\_secret\_name)

Description: Wildcard SSL certificate pfx blob Key Vault secret name, for Custom Domain binding.

Type: `string`

Default: `null`
## Modules

The following Modules are called:

### <a name="module_diagnostic-settings"></a> [diagnostic-settings](#module\_diagnostic-settings)

Source: ../diagnostic-settings

Version:
## Outputs

The following outputs are exported:

### <a name="output_app_service_plan_id"></a> [app\_service\_plan\_id](#output\_app\_service\_plan\_id)

Description: n/a

### <a name="output_app_service_plan_name"></a> [app\_service\_plan\_name](#output\_app\_service\_plan\_name)

Description: n/a

### <a name="output_wildcard_ssl_cert_id"></a> [wildcard\_ssl\_cert\_id](#output\_wildcard\_ssl\_cert\_id)

Description: n/a
## Resources

The following resources are used by this module:

- [azurerm_app_service_certificate.wildcard](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_certificate) (resource)
- [azurerm_app_service_virtual_network_swift_connection.appservice_vnet_swift_connection](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_virtual_network_swift_connection) (resource)
- [azurerm_monitor_autoscale_setting.asp_autoscale](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_autoscale_setting) (resource)
- [azurerm_service_plan.appserviceplan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) (resource)
- [azurerm_key_vault_secret.pfx_blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
