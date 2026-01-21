# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description: The location/region where the Relay namespace is created.

Type: `string`

### <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id)

Description: ID of the Log Analytics workspace to send resource logging to via diagnostic settings.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the Azure Relay namespace.

Type: `string`

### <a name="input_private_endpoint_properties"></a> [private\_endpoint\_properties](#input\_private\_endpoint\_properties)

Description: Consolidated properties for the Azure Relay Private Endpoint.

Type:

```hcl
object({
    private_dns_zone_ids_relay           = optional(list(string), [])
    private_endpoint_enabled             = optional(bool, false)
    private_endpoint_subnet_id           = optional(string, "")
    private_endpoint_resource_group_name = optional(string, "")
    private_service_connection_is_manual = optional(bool, false)
  })
```

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which to create the Relay namespace.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_monitor_diagnostic_setting_relay_enabled_logs"></a> [monitor\_diagnostic\_setting\_relay\_enabled\_logs](#input\_monitor\_diagnostic\_setting\_relay\_enabled\_logs)

Description: Controls what logs will be enabled for the Relay namespace.

Type: `list(string)`

Default:

```json
[
  "HybridConnectionsEvent"
]
```

### <a name="input_monitor_diagnostic_setting_relay_metrics"></a> [monitor\_diagnostic\_setting\_relay\_metrics](#input\_monitor\_diagnostic\_setting\_relay\_metrics)

Description: Controls what metrics will be enabled for the Relay namespace.

Type: `list(string)`

Default:

```json
[
  "AllMetrics"
]
```

### <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name)

Description: The SKU for the Relay namespace. Only 'Standard' is supported.

Type: `string`

Default: `"Standard"`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: A mapping of tags to assign to the resource.

Type: `map(string)`

Default: `{}`
## Modules

The following Modules are called:

### <a name="module_diagnostic-settings"></a> [diagnostic-settings](#module\_diagnostic-settings)

Source: ../diagnostic-settings

Version:

### <a name="module_private_endpoint_relay"></a> [private\_endpoint\_relay](#module\_private\_endpoint\_relay)

Source: ../private-endpoint

Version:
## Outputs

The following outputs are exported:

### <a name="output_id"></a> [id](#output\_id)

Description: The ID of the Relay namespace.

### <a name="output_name"></a> [name](#output\_name)

Description: The name of the Relay namespace.

### <a name="output_primary_connection_string"></a> [primary\_connection\_string](#output\_primary\_connection\_string)

Description: The primary connection string for the Relay namespace.

### <a name="output_primary_key"></a> [primary\_key](#output\_primary\_key)

Description: The primary access key for the Relay namespace.

### <a name="output_secondary_connection_string"></a> [secondary\_connection\_string](#output\_secondary\_connection\_string)

Description: The secondary connection string for the Relay namespace.

### <a name="output_secondary_key"></a> [secondary\_key](#output\_secondary\_key)

Description: The secondary access key for the Relay namespace.
## Resources

The following resources are used by this module:

- [azurerm_relay_namespace.relay](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/relay_namespace) (resource)
