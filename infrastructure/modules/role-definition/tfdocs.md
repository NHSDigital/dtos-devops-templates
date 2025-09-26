# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_assignable_scopes"></a> [assignable\_scopes](#input\_assignable\_scopes)

Description: A collection of one or more scopes at which this definition can be assigned.

Type: `list(string)`

### <a name="input_environment"></a> [environment](#input\_environment)

Description: The environment name (e.g., dev, prod)

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: A user-defined name for this custom role definition

Type: `string`

### <a name="input_permissions"></a> [permissions](#input\_permissions)

Description:     A set of permissions to apply to the role definition. Please refer to the relevant Microsoft
    documentation related to the available "actions", "data actions", and any "not actions" available.
    Example:

      {
        actions           = ["Microsoft.Storage/storageAccounts/listkeys/action"]
        data\_actions      = ["Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read"]
        not\_actions       = []
        not\_data\_actions  = []
      }

Type:

```hcl
object({
    actions          = optional(list(string), [])
    data_actions     = optional(list(string), [])
    not_actions      = optional(list(string), [])
    not_data_actions = optional(list(string), [])
  })
```

### <a name="input_scope"></a> [scope](#input\_scope)

Description: The resource group or subscription ID that acts as the main scope at which this custom role definition will apply.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_description"></a> [description](#input\_description)

Description: A friendly textual description of this role and its intended purpose.

Type: `string`

Default: `"Custom role for managing access to Azure resources in the specified environment."`

## Outputs

The following outputs are exported:

### <a name="output_role_definition_id"></a> [role\_definition\_id](#output\_role\_definition\_id)

Description: n/a

### <a name="output_role_definition_name"></a> [role\_definition\_name](#output\_role\_definition\_name)

Description: The name of the custom role definition
## Resources

The following resources are used by this module:

- [azurerm_role_definition.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) (resource)
