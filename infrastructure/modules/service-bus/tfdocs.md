# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_private_endpoint_properties"></a> [private\_endpoint\_properties](#input\_private\_endpoint\_properties)

Description: Consolidated properties for the Service Bus Private Endpoint.

Type:

```hcl
object({
    private_dns_zone_ids                 = optional(list(string), [])
    private_endpoint_enabled             = optional(bool, false)
    private_endpoint_subnet_id           = optional(string, "")
    private_endpoint_resource_group_name = optional(string, "")
    private_service_connection_is_manual = optional(bool, false)
  })
```

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which to create the Event Grid. Changing this forces a new resource to be created.

Type: `string`

### <a name="input_servicebus_namespace_name"></a> [servicebus\_namespace\_name](#input\_servicebus\_namespace\_name)

Description: The name of the Service Bus namespace.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_capacity"></a> [capacity](#input\_capacity)

Description: When sku is Premium, capacity can be 1, 2, 4, 8 or 16. When sku is Basic or Standard, capacity must be 0.

Type: `number`

Default: `0`

### <a name="input_location"></a> [location](#input\_location)

Description: The location/region where the Service Bus namespace will be created.

Type: `string`

Default: `"uksouth"`

### <a name="input_partitioning_enabled"></a> [partitioning\_enabled](#input\_partitioning\_enabled)

Description: Boolean flag which controls whether to enable the topic to be partitioned across multiple message brokers. Changing this forces a new resource to be created.

Type: `bool`

Default: `false`

### <a name="input_premium_messaging_partitions"></a> [premium\_messaging\_partitions](#input\_premium\_messaging\_partitions)

Description: Boolean flag which controls whether to enable the topic to be partitioned across multiple message brokers. Changing this forces a new resource to be created.

Type: `number`

Default: `1`

### <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled)

Description: n/a

Type: `bool`

Default: `false`

### <a name="input_servicebus_topic_map"></a> [servicebus\_topic\_map](#input\_servicebus\_topic\_map)

Description: n/a

Type:

```hcl
map(object({
    auto_delete_on_idle                     = optional(string, "P10675199DT2H48M5.4775807S")
    batched_operations_enabled              = optional(bool, false)
    default_message_ttl                     = optional(string, "P10675199DT2H48M5.4775807S")
    duplicate_detection_history_time_window = optional(string)
    partitioning_enabled                    = optional(bool, false)
    max_message_size_in_kilobytes           = optional(number, 1024)
    max_size_in_megabytes                   = optional(number, 5120)
    requires_duplicate_detection            = optional(bool, false)
    support_ordering                        = optional(bool)
    status                                  = optional(string, "Active")
    topic_name                              = optional(string)
  }))
```

Default: `{}`

### <a name="input_sku_tier"></a> [sku\_tier](#input\_sku\_tier)

Description: The tier of the SKU.

Type: `string`

Default: `"Standard"`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: A mapping of tags to assign to the resource.

Type: `map(string)`

Default: `{}`
## Modules

The following Modules are called:

### <a name="module_private_endpoint_service_bus_namespace"></a> [private\_endpoint\_service\_bus\_namespace](#module\_private\_endpoint\_service\_bus\_namespace)

Source: ../private-endpoint

Version:
## Outputs

The following outputs are exported:

### <a name="output_namespace_id"></a> [namespace\_id](#output\_namespace\_id)

Description: n/a

### <a name="output_namespace_name"></a> [namespace\_name](#output\_namespace\_name)

Description: n/a

### <a name="output_servicebus_connection_string"></a> [servicebus\_connection\_string](#output\_servicebus\_connection\_string)

Description: n/a

### <a name="output_topic_ids"></a> [topic\_ids](#output\_topic\_ids)

Description: n/a
## Resources

The following resources are used by this module:

- [azurerm_servicebus_namespace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace) (resource)
- [azurerm_servicebus_namespace_authorization_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace_authorization_rule) (resource)
- [azurerm_servicebus_topic.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_topic) (resource)
