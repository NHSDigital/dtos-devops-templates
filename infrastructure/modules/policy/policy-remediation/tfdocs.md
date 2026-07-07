# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_policy_assignment_id"></a> [policy\_assignment\_id](#input\_policy\_assignment\_id)

Description: The identifier of a specific policy assignment.

Type: `string`

### <a name="input_remediation_name"></a> [remediation\_name](#input\_remediation\_name)

Description: The policy remediation name.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_resource_id"></a> [resource\_id](#input\_resource\_id)

Description: The identifier of a specific resource to apply this policy onto.

Type: `string`

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_policy_remediation_id"></a> [policy\_remediation\_id](#output\_policy\_remediation\_id)

Description: The ID of the created policy remediation.
## Resources

The following resources are used by this module:

- [azurerm_resource_policy_remediation.remediation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_policy_remediation) (resource)
