# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id)

Description: The ID of the Log Analytics workspace to send diagnostic logs to.

Type: `string`

### <a name="input_monitor_diagnostic_setting_bastion_enabled_logs"></a> [monitor\_diagnostic\_setting\_bastion\_enabled\_logs](#input\_monitor\_diagnostic\_setting\_bastion\_enabled\_logs)

Description: List of log categories to enable for the Bastion diagnostic setting (e.g. ["BastionAuditLogs"]).

Type: `list(string)`

### <a name="input_monitor_diagnostic_setting_bastion_metrics"></a> [monitor\_diagnostic\_setting\_bastion\_metrics](#input\_monitor\_diagnostic\_setting\_bastion\_metrics)

Description: List of metric categories to enable for the Bastion diagnostic setting (e.g. ["AllMetrics"]).

Type: `list(string)`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the Azure Bastion host.

Type: `string`

### <a name="input_public_ip_name"></a> [public\_ip\_name](#input\_public\_ip\_name)

Description: The name of the public IP address resource created for the Bastion host.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which to create the Bastion host.

Type: `string`

### <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id)

Description: The ID of the AzureBastionSubnet in which the Bastion host will be deployed.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_copy_paste_enabled"></a> [copy\_paste\_enabled](#input\_copy\_paste\_enabled)

Description: Is copy/paste feature enabled for the Bastion host.

Type: `bool`

Default: `true`

### <a name="input_file_copy_enabled"></a> [file\_copy\_enabled](#input\_file\_copy\_enabled)

Description: Is file copy feature enabled for the Bastion host. Requires Standard SKU or higher.

Type: `bool`

Default: `false`

### <a name="input_ip_connect_enabled"></a> [ip\_connect\_enabled](#input\_ip\_connect\_enabled)

Description: Is IP connect feature enabled for the Bastion host. Requires Standard SKU or higher.

Type: `bool`

Default: `false`

### <a name="input_location"></a> [location](#input\_location)

Description: The location/region where the Bastion host will be created.

Type: `string`

Default: `"uksouth"`

### <a name="input_scale_units"></a> [scale\_units](#input\_scale\_units)

Description: The number of scale units for the Bastion host. Each unit supports ~20 concurrent RDP / ~40 concurrent SSH sessions. Must be between 2 and 50 for Standard/Premium SKU; Basic is fixed at 2.

Type: `number`

Default: `2`

### <a name="input_shareable_link_enabled"></a> [shareable\_link\_enabled](#input\_shareable\_link\_enabled)

Description: Is shareable link feature enabled for the Bastion host. Requires Standard SKU or higher.

Type: `bool`

Default: `false`

### <a name="input_sku"></a> [sku](#input\_sku)

Description: The SKU tier of the Bastion host. Possible values are Basic, Standard, and Premium. Standard is recommended for most production workloads; Premium adds session recording and private-only deployment. Developer SKU is not supported by this module as it does not use a public IP or dedicated subnet.

Type: `string`

Default: `"Standard"`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: A mapping of tags to assign to the resource.

Type: `map(string)`

Default: `{}`

### <a name="input_tunneling_enabled"></a> [tunneling\_enabled](#input\_tunneling\_enabled)

Description: Is tunneling (native client support) feature enabled for the Bastion host. Enables native SSH/RDP client connections via az network bastion ssh/rdp. Recommended for Standard SKU or higher.

Type: `bool`

Default: `false`

### <a name="input_zones"></a> [zones](#input\_zones)

Description: Availability zones for the public IP address. Use ["1", "2", "3"] for zone-redundant deployment, which is recommended for production environments. An empty list deploys with no zone redundancy.

Type: `list(string)`

Default: `[]`
## Modules

The following Modules are called:

### <a name="module_diagnostic_settings"></a> [diagnostic\_settings](#module\_diagnostic\_settings)

Source: ../diagnostic-settings

Version:

### <a name="module_pip"></a> [pip](#module\_pip)

Source: ../public-ip

Version:
## Outputs

The following outputs are exported:

### <a name="output_dns_name"></a> [dns\_name](#output\_dns\_name)

Description: The FQDN of the Bastion host.

### <a name="output_id"></a> [id](#output\_id)

Description: The ID of the Bastion host.

### <a name="output_name"></a> [name](#output\_name)

Description: The name of the Bastion host.

### <a name="output_public_ip_address"></a> [public\_ip\_address](#output\_public\_ip\_address)

Description: The public IP address associated with the Bastion host.
## Resources

The following resources are used by this module:

- [azurerm_bastion_host.bastion](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/bastion_host) (resource)
