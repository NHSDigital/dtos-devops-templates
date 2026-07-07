# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_display_name"></a> [display\_name](#input\_display\_name)

Description: Display name for the policy.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: Policy definition name.

Type: `string`

### <a name="input_policy_rule"></a> [policy\_rule](#input\_policy\_rule)

Description: Azure Policy Rule object. Must follow Microsoft schema:
{
  "if": {
    <condition> | <logical operator> | nested conditions
  },
  "then": {
    "effect": "deny | audit | modify | denyAction | append | auditIfNotExists | deployIfNotExists | disabled"
    "details": <policy details>
  }
}

Type:

```hcl
object({
    if = any
    then = object({
      effect  = string
      details = optional(any)
    })
  })
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_description"></a> [description](#input\_description)

Description: Description of the policy.

Type: `string`

Default: `""`

### <a name="input_metadata"></a> [metadata](#input\_metadata)

Description: Metadata for the policy.

Type: `map(any)`

Default: `{}`

### <a name="input_mode"></a> [mode](#input\_mode)

Description: Determines which resource types are evaluated for a policy definition

Type: `string`

Default: `"All"`

### <a name="input_parameters"></a> [parameters](#input\_parameters)

Description: Policy parameters.

Type: `map(any)`

Default: `{}`

### <a name="input_policy_type"></a> [policy\_type](#input\_policy\_type)

Description: Type of policy.

Type: `string`

Default: `"Custom"`

## Outputs

The following outputs are exported:

### <a name="output_policy_definition_id"></a> [policy\_definition\_id](#output\_policy\_definition\_id)

Description: The ID of the created policy definition.

### <a name="output_policy_requires_identity"></a> [policy\_requires\_identity](#output\_policy\_requires\_identity)

Description: True if this policy must be assigned a managed identity, false otherwise
## Resources

The following resources are used by this module:

- [azurerm_policy_definition.definition](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_definition) (resource)
