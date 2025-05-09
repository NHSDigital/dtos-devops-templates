# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description: n/a

Type: `any`

### <a name="input_names"></a> [names](#input\_names)

Description: n/a

Type: `map(string)`

### <a name="input_resource_groups_audit"></a> [resource\_groups\_audit](#input\_resource\_groups\_audit)

Description: n/a

Type:

```hcl
map(object({
    name     = string
    location = string
  }))
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_tags"></a> [tags](#input\_tags)

Description: n/a

Type: `map`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_resource_group_ids_audit"></a> [resource\_group\_ids\_audit](#output\_resource\_group\_ids\_audit)

Description: The IDs of the created resource groups

### <a name="output_resource_group_locations_audit"></a> [resource\_group\_locations\_audit](#output\_resource\_group\_locations\_audit)

Description: The locations of the created resource groups

### <a name="output_resource_group_names_audit"></a> [resource\_group\_names\_audit](#output\_resource\_group\_names\_audit)

Description: The names of the created resource groups

### <a name="output_resource_groupsrg_audit"></a> [resource\_groupsrg\_audit](#output\_resource\_groupsrg\_audit)

Description: n/a
## Resources

The following resources are used by this module:

- [azurerm_resource_group.rg-audit](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
