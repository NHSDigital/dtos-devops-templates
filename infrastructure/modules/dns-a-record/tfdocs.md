# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_name"></a> [name](#input\_name)

Description: n/a

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: n/a

Type: `string`

### <a name="input_ttl"></a> [ttl](#input\_ttl)

Description: n/a

Type: `string`

### <a name="input_zone_name"></a> [zone\_name](#input\_zone\_name)

Description: n/a

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_records"></a> [records](#input\_records)

Description: n/a

Type: `list(string)`

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: A mapping of tags to assign to the resource.

Type: `map(string)`

Default: `{}`

### <a name="input_target_resource_id"></a> [target\_resource\_id](#input\_target\_resource\_id)

Description: n/a

Type: `string`

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_fqdn"></a> [fqdn](#output\_fqdn)

Description: n/a

### <a name="output_id"></a> [id](#output\_id)

Description: n/a
## Resources

The following resources are used by this module:

- [azurerm_dns_a_record.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_a_record) (resource)
