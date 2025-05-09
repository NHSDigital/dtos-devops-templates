# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type)

Description: The identity type of the Event Grid.

Type: `string`

### <a name="input_location"></a> [location](#input\_location)

Description: The location/region where the Event Grid is created.

Type: `string`

### <a name="input_private_endpoint_properties"></a> [private\_endpoint\_properties](#input\_private\_endpoint\_properties)

Description: Consolidated properties for the Event Grid Private Endpoint.

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

### <a name="input_topic_name"></a> [topic\_name](#input\_topic\_name)

Description: The name of the Event Grid topic.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_inbound_ip_rules"></a> [inbound\_ip\_rules](#input\_inbound\_ip\_rules)

Description: List of inbound IP rules

Type:

```hcl
list(object({
    ip_mask = string
    action  = string
  }))
```

Default: `[]`

### <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled)

Description: Whether or not public network access is allowed for Event Grid.

Type: `string`

Default: `false`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: A mapping of tags to assign to the Event Grid topic.

Type: `map(string)`

Default: `{}`
## Modules

The following Modules are called:

### <a name="module_private_endpoint_eventgrid"></a> [private\_endpoint\_eventgrid](#module\_private\_endpoint\_eventgrid)

Source: ../private-endpoint

Version:
## Outputs

The following outputs are exported:

### <a name="output_id"></a> [id](#output\_id)

Description: The event grid topic id.

### <a name="output_topic_endpoint"></a> [topic\_endpoint](#output\_topic\_endpoint)

Description: The event grid topic URL.
## Resources

The following resources are used by this module:

- [azurerm_eventgrid_topic.azurerm_eventgrid](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventgrid_topic) (resource)
