# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_firewall_name"></a> [firewall\_name](#input\_firewall\_name)

Description: The name of the firewall.

Type: `string`

### <a name="input_policy_name"></a> [policy\_name](#input\_policy\_name)

Description: The name of the firewall policy

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which to create the firewall.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_dns_proxy_enabled"></a> [dns\_proxy\_enabled](#input\_dns\_proxy\_enabled)

Description: Is DNS proxy enabled for the firewall policy

Type: `bool`

Default: `false`

### <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers)

Description: The DNS servers for the firewall policy

Type: `list(string)`

Default: `[]`

### <a name="input_ip_configuration"></a> [ip\_configuration](#input\_ip\_configuration)

Description: List of public ips' ids to attach to the firewall.

Type:

```hcl
list(object({
    name                 = string
    public_ip_address_id = string
    firewall_subnet_id   = string
  }))
```

Default: `[]`

### <a name="input_location"></a> [location](#input\_location)

Description: The location/region where the firewall will be created.

Type: `string`

Default: `"uksouth"`

### <a name="input_sku"></a> [sku](#input\_sku)

Description: The SKU of the firewall policy

Type: `string`

Default: `"Standard"`

### <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name)

Description: The tier of the SKU.

Type: `string`

Default: `"AZFW_VNet"`

### <a name="input_sku_tier"></a> [sku\_tier](#input\_sku\_tier)

Description: The tier of the SKU.

Type: `string`

Default: `"Standard"`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: A mapping of tags to assign to the resource.

Type: `map(string)`

Default: `{}`

### <a name="input_threat_intelligence_mode"></a> [threat\_intelligence\_mode](#input\_threat\_intelligence\_mode)

Description: The threat intelligence mode of the firewall policy

Type: `string`

Default: `"Alert"`

### <a name="input_zones"></a> [zones](#input\_zones)

Description: Specifies a list of Availability Zones in which this Azure Firewall should be located. Changing this forces a new Azure Firewall to be created.

Type: `list(string)`

Default: `null`
## Modules

The following Modules are called:

### <a name="module_firewall-policy"></a> [firewall-policy](#module\_firewall-policy)

Source: ../firewall-policy

Version:
## Outputs

The following outputs are exported:

### <a name="output_firewall_policy_id"></a> [firewall\_policy\_id](#output\_firewall\_policy\_id)

Description: n/a

### <a name="output_id"></a> [id](#output\_id)

Description: n/a

### <a name="output_name"></a> [name](#output\_name)

Description: n/a

### <a name="output_private_ip_address"></a> [private\_ip\_address](#output\_private\_ip\_address)

Description: n/a
## Resources

The following resources are used by this module:

- [azurerm_firewall.firewall](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall) (resource)
