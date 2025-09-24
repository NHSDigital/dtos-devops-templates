# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_assignable_scopes"></a> [assignable\_scopes](#input\_assignable\_scopes)

Description: A collection of one or more scopes at which this definition can be assigned.

Type: `list(string)`

### <a name="input_environment"></a> [environment](#input\_environment)

Description: A code of the environment in which to create the user-assigned identity and role assignments.

Type: `string`

### <a name="input_location"></a> [location](#input\_location)

Description: The region where the user assigned identity must be created.

Type: `string`

### <a name="input_role_name"></a> [role\_name](#input\_role\_name)

Description: A name to apply to the single global role definition

Type: `string`

### <a name="input_role_scope_id"></a> [role\_scope\_id](#input\_role\_scope\_id)

Description: The ID of a resource group or subscription for this custom role definition

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_tags"></a> [tags](#input\_tags)

Description: Resource tags to be applied throughout the deployment.

Type: `map(string)`

Default: `{}`
## Modules

The following Modules are called:

### <a name="module_global_role_definition_rw"></a> [global\_role\_definition\_rw](#module\_global\_role\_definition\_rw)

Source: ../role-definition

Version:
## Outputs

The following outputs are exported:

### <a name="output_role_definition_id"></a> [role\_definition\_id](#output\_role\_definition\_id)

Description: n/a
## Resources

The following resources are used by this module:

- [azurerm_role_definition.contributor_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/role_definition) (data source)
- [azurerm_role_definition.reader_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/role_definition) (data source)
