# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_display_name"></a> [display\_name](#input\_display\_name)

Description: Initiative display name.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: Initiative name.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_description"></a> [description](#input\_description)

Description: Description of the initiative.

Type: `string`

Default: `""`

### <a name="input_policy_definitions"></a> [policy\_definitions](#input\_policy\_definitions)

Description: List of policy definitions included in the initiative.

Type:

```hcl
list(object({
    id           = string
    parameters   = optional(any)
    reference_id = optional(string)
  }))
```

Default: `[]`

### <a name="input_policy_type"></a> [policy\_type](#input\_policy\_type)

Description: Type of the initiative, whether it is custom or pre-existing.

Type: `string`

Default: `"custom"`

## Outputs

The following outputs are exported:

### <a name="output_initiative_id"></a> [initiative\_id](#output\_initiative\_id)

Description: ID of the created policy initiative.
## Resources

The following resources are used by this module:

- [azurerm_policy_set_definition.item](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_set_definition) (resource)
