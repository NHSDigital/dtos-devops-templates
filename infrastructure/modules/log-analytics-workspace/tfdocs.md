# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_law_sku"></a> [law\_sku](#input\_law\_sku)

Description: The SKU for LAW.

Type: `string`

### <a name="input_location"></a> [location](#input\_location)

Description: The location/region where the LAW is created.

Type: `string`

### <a name="input_monitor_diagnostic_setting_log_analytics_workspace_enabled_logs"></a> [monitor\_diagnostic\_setting\_log\_analytics\_workspace\_enabled\_logs](#input\_monitor\_diagnostic\_setting\_log\_analytics\_workspace\_enabled\_logs)

Description: Controls what logs will be enabled for the Long Analytics Workspace

Type: `list(string)`

### <a name="input_monitor_diagnostic_setting_log_analytics_workspace_metrics"></a> [monitor\_diagnostic\_setting\_log\_analytics\_workspace\_metrics](#input\_monitor\_diagnostic\_setting\_log\_analytics\_workspace\_metrics)

Description: Controls what metrics will be enabled for the Long Analytics Workspace

Type: `list(string)`

### <a name="input_name"></a> [name](#input\_name)

Description: Is the LAW name.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which the Log Analytics Workspace is created. Changing this forces a new resource to be created.

Type: `string`

### <a name="input_retention_days"></a> [retention\_days](#input\_retention\_days)

Description: Retention days for LAW.

Type: `number`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_tags"></a> [tags](#input\_tags)

Description: A mapping of tags to assign to the resource.

Type: `map(string)`

Default: `{}`
## Modules

The following Modules are called:

### <a name="module_diagnostic-settings"></a> [diagnostic-settings](#module\_diagnostic-settings)

Source: ../diagnostic-settings

Version:
## Outputs

The following outputs are exported:

### <a name="output_id"></a> [id](#output\_id)

Description: n/a

### <a name="output_identity"></a> [identity](#output\_identity)

Description: The Managed Service Identity that is created by defaults for this Log Analytics Workspace.

### <a name="output_name"></a> [name](#output\_name)

Description: n/a
## Resources

The following resources are used by this module:

- [azurerm_log_analytics_workspace.log_analytics_workspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) (resource)
