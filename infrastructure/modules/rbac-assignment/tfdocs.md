# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_principal_id"></a> [principal\_id](#input\_principal\_id)

Description: The principal ID (e.g., user, group, or service principal) to which the role will be assigned.

Type: `string`

### <a name="input_role_definition_name"></a> [role\_definition\_name](#input\_role\_definition\_name)

Description: The name of the role definition to assign.

Type: `string`

### <a name="input_scope"></a> [scope](#input\_scope)

Description: The scope at which the role assignment will be created.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_skip_service_principal_aad_check"></a> [skip\_service\_principal\_aad\_check](#input\_skip\_service\_principal\_aad\_check)

Description: Enable skipping the principal aad check.

Type: `bool`

Default: `false`

## Outputs

The following outputs are exported:

### <a name="output_id"></a> [id](#output\_id)

Description: n/a

### <a name="output_name"></a> [name](#output\_name)

Description: n/a
## Resources

The following resources are used by this module:

- [azurerm_role_assignment.role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
