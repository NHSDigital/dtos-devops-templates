# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_assignment_name"></a> [assignment\_name](#input\_assignment\_name)

Description: A short name for this policy assignment

Type: `string`

### <a name="input_display_name"></a> [display\_name](#input\_display\_name)

Description: Policy assignment display name.

Type: `string`

### <a name="input_policy_assignment_scope"></a> [policy\_assignment\_scope](#input\_policy\_assignment\_scope)

Description: The scope at which this assignment is assigned

Type: `string`

### <a name="input_policy_definition_id"></a> [policy\_definition\_id](#input\_policy\_definition\_id)

Description: An identifier of a policy definition to assign.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_create_remediator_role"></a> [create\_remediator\_role](#input\_create\_remediator\_role)

Description: True to create an associated Policy Contributor role, false otherwise

Type: `bool`

Default: `false`

### <a name="input_description"></a> [description](#input\_description)

Description: Description of the policy assignment.

Type: `string`

Default: `""`

### <a name="input_enabled_log"></a> [enabled\_log](#input\_enabled\_log)

Description: Collection of logs to capture

Type: `list(string)`

Default: `[]`

### <a name="input_enabled_metric"></a> [enabled\_metric](#input\_enabled\_metric)

Description: Collection of metrics to capture

Type: `list(string)`

Default: `[]`

### <a name="input_enforce_policy"></a> [enforce\_policy](#input\_enforce\_policy)

Description: True if this policy should be enforced, false otherwise

Type: `bool`

Default: `true`

### <a name="input_log_analytics_wks_id"></a> [log\_analytics\_wks\_id](#input\_log\_analytics\_wks\_id)

Description: An identifier of a specific Log Analytics Workspace instance to use

Type: `string`

Default: `null`

### <a name="input_parameters"></a> [parameters](#input\_parameters)

Description: Parameters for the policy assignment.

Type: `map(any)`

Default: `{}`

### <a name="input_policy_assignment_principal_id"></a> [policy\_assignment\_principal\_id](#input\_policy\_assignment\_principal\_id)

Description: The identifier of a specific service principal to use for the policy assignment

Type: `string`

Default: `null`

### <a name="input_policy_identities"></a> [policy\_identities](#input\_policy\_identities)

Description: A collection of principal identifiers assigned to this policy. Only required if the identity type is 'UserAssigned'

Type: `list(string)`

Default: `[]`

### <a name="input_policy_location"></a> [policy\_location](#input\_policy\_location)

Description: Defines where the policy will be deployed to. Required if identify is provided.

Type: `string`

Default: `"uksouth"`

### <a name="input_requires_identity"></a> [requires\_identity](#input\_requires\_identity)

Description: True if the policy requires a managed identity, false otherwise

Type: `bool`

Default: `false`

### <a name="input_resource_id"></a> [resource\_id](#input\_resource\_id)

Description: An identifier of a specific resource to apply this policy onto

Type: `string`

Default: `null`
## Modules

The following Modules are called:

### <a name="module_policy_assignment_logs"></a> [policy\_assignment\_logs](#module\_policy\_assignment\_logs)

Source: ../../diagnostic-settings

Version:
## Outputs

The following outputs are exported:

### <a name="output_policy_assignment_id"></a> [policy\_assignment\_id](#output\_policy\_assignment\_id)

Description: ID of the policy assignment.

### <a name="output_policy_principal_id"></a> [policy\_principal\_id](#output\_policy\_principal\_id)

Description: Principal ID of the system-assigned identity (if created)
## Resources

The following resources are used by this module:

- [azurerm_resource_group_policy_assignment.rg_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) (resource)
- [azurerm_resource_policy_assignment.res_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_policy_assignment) (resource)
- [azurerm_role_assignment.role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_subscription_policy_assignment.sub_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription_policy_assignment) (resource)
