# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description: The region where the VNET should be created.

Type: `string`

### <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id)

Description: id of the log analytics workspace to send resource logging to via diagnostic settings

Type: `string`

### <a name="input_monitor_diagnostic_setting_vnet_enabled_logs"></a> [monitor\_diagnostic\_setting\_vnet\_enabled\_logs](#input\_monitor\_diagnostic\_setting\_vnet\_enabled\_logs)

Description: Controls what logs will be enabled for the vnet

Type: `list(string)`

### <a name="input_monitor_diagnostic_setting_vnet_metrics"></a> [monitor\_diagnostic\_setting\_vnet\_metrics](#input\_monitor\_diagnostic\_setting\_vnet\_metrics)

Description: Controls what metrics will be enabled for the vnet

Type: `list(string)`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the vnet.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which to create the VNET. Changing this forces a new resource to be created.

Type: `string`

### <a name="input_vnet_address_space"></a> [vnet\_address\_space](#input\_vnet\_address\_space)

Description: n/a

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers)

Description: The DNS servers to be used by the VNET.

Type: `list(string)`

Default: `[]`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: Resource tags to be applied throughout the deployment.

Type: `map(string)`

Default: `{}`
## Modules

The following Modules are called:

### <a name="module_diagnostic-settings"></a> [diagnostic-settings](#module\_diagnostic-settings)

Source: ../diagnostic-settings

Version:
## Outputs

The following outputs are exported:

### <a name="output_name"></a> [name](#output\_name)

Description: n/a

### <a name="output_vnet"></a> [vnet](#output\_vnet)

Description: n/a
## Resources

The following resources are used by this module:

- [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) (resource)
