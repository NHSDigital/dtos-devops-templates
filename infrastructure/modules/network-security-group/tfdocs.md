# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description: location

Type: `string`

### <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id)

Description: id of the log analytics workspace to send resource logging to via diagnostic settings

Type: `string`

### <a name="input_monitor_diagnostic_setting_network_security_group_enabled_logs"></a> [monitor\_diagnostic\_setting\_network\_security\_group\_enabled\_logs](#input\_monitor\_diagnostic\_setting\_network\_security\_group\_enabled\_logs)

Description: Controls what logs will be enabled for the NSG

Type: `list(string)`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the nsg.

Type: `string`

### <a name="input_nsg_rules"></a> [nsg\_rules](#input\_nsg\_rules)

Description: Additional NSG rules for securing subnets (Optional).

Type:

```hcl
list(object({
    name                         = string
    priority                     = number
    direction                    = string
    access                       = string
    protocol                     = string
    source_port_range            = optional(string)
    source_port_ranges           = optional(list(string))
    destination_port_range       = optional(string)
    destination_port_ranges      = optional(list(string))
    source_address_prefix        = optional(string)
    source_address_prefixes      = optional(list(string))
    destination_address_prefix   = optional(string)
    destination_address_prefixes = optional(list(string))
  }))
```

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which to create the NSG. Changing this forces a new resource to be created.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

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

### <a name="output_id"></a> [id](#output\_id)

Description: n/a

### <a name="output_name"></a> [name](#output\_name)

Description: n/a
## Resources

The following resources are used by this module:

- [azurerm_network_security_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) (resource)
