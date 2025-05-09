# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_auth_rule"></a> [auth\_rule](#input\_auth\_rule)

Description: Authorization rule settings for the Event Hub namespace.

Type:

```hcl
object({
    listen = optional(bool, true)
    send   = optional(bool, false)
    manage = optional(bool, false)
  })
```

### <a name="input_auto_inflate"></a> [auto\_inflate](#input\_auto\_inflate)

Description: Whether auto-inflate is enabled for the Event Hub namespace.

Type: `bool`

### <a name="input_event_hubs"></a> [event\_hubs](#input\_event\_hubs)

Description: A map of Event Hubs to create within the namespace.

Type:

```hcl
map(object({
    name              = string
    consumer_group    = string
    partition_count   = number
    message_retention = number
  }))
```

### <a name="input_location"></a> [location](#input\_location)

Description: The location/region where the Event Hub namespace is created.

Type: `string`

### <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id)

Description: id of the log analytics workspace to send resource logging to via diagnostic settings

Type: `string`

### <a name="input_maximum_throughput_units"></a> [maximum\_throughput\_units](#input\_maximum\_throughput\_units)

Description: The maximum throughput units for the Event Hub namespace when auto-inflate is enabled.

Type: `number`

### <a name="input_minimum_tls_version"></a> [minimum\_tls\_version](#input\_minimum\_tls\_version)

Description: The minimum TLS version for the Event Hub namespace.

Type: `string`

### <a name="input_monitor_diagnostic_setting_eventhub_enabled_logs"></a> [monitor\_diagnostic\_setting\_eventhub\_enabled\_logs](#input\_monitor\_diagnostic\_setting\_eventhub\_enabled\_logs)

Description: Controls what logs will be enabled for the eventhub

Type: `list(string)`

### <a name="input_monitor_diagnostic_setting_eventhub_metrics"></a> [monitor\_diagnostic\_setting\_eventhub\_metrics](#input\_monitor\_diagnostic\_setting\_eventhub\_metrics)

Description: Controls what metrics will be enabled for the eventhub

Type: `list(string)`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the Event Hub namespace.

Type: `string`

### <a name="input_private_endpoint_properties"></a> [private\_endpoint\_properties](#input\_private\_endpoint\_properties)

Description: Consolidated properties for the Key Vault Private Endpoint.

Type:

```hcl
object({
    private_dns_zone_ids_eventhub        = optional(list(string), [])
    private_endpoint_enabled             = optional(bool, false)
    private_endpoint_subnet_id           = optional(string, "")
    private_endpoint_resource_group_name = optional(string, "")
    private_service_connection_is_manual = optional(bool, false)
  })
```

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which to create the Event Hub namespace.

Type: `string`

### <a name="input_sku"></a> [sku](#input\_sku)

Description: The SKU for the Event Hub namespace. Note that setting this to Premium will force the creation of a new resource.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_capacity"></a> [capacity](#input\_capacity)

Description: Specifies the Capacity / Throughput Units for a Standard SKU namespace. Default capacity has a maximum of 2, but can be increased in blocks of 2 on a committed purchase basis. Defaults to 1.

Type: `number`

Default: `1`

### <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled)

Description: Controls whether data in the account may be accessed from public networks.

Type: `bool`

Default: `false`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: A mapping of tags to assign to the resource.

Type: `map(string)`

Default: `{}`
## Modules

The following Modules are called:

### <a name="module_diagnostic-settings"></a> [diagnostic-settings](#module\_diagnostic-settings)

Source: ../diagnostic-settings

Version:

### <a name="module_private_endpoint_eventhub"></a> [private\_endpoint\_eventhub](#module\_private\_endpoint\_eventhub)

Source: ../private-endpoint

Version:
## Outputs

The following outputs are exported:

### <a name="output_event_hubs"></a> [event\_hubs](#output\_event\_hubs)

Description: n/a

### <a name="output_id"></a> [id](#output\_id)

Description: n/a

### <a name="output_name"></a> [name](#output\_name)

Description: n/a
## Resources

The following resources are used by this module:

- [azurerm_eventhub.eventhub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub) (resource)
- [azurerm_eventhub_consumer_group.consumer_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_consumer_group) (resource)
- [azurerm_eventhub_namespace.eventhub_ns](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace) (resource)
- [azurerm_eventhub_namespace_authorization_rule.auth_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace_authorization_rule) (resource)
- [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
