# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_function_app_id"></a> [function\_app\_id](#input\_function\_app\_id)

Description: The ID of the function App.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: The function app slot name.

Type: `string`

### <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name)

Description: The storage account name.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_function_app_slot_enabled"></a> [function\_app\_slot\_enabled](#input\_function\_app\_slot\_enabled)

Description: If slots are enabled or not.

Type: `bool`

Default: `false`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: Resource tags to be applied throughout the deployment.

Type: `map(string)`

Default: `{}`


## Resources

The following resources are used by this module:

- [azurerm_linux_function_app_slot.function_app_slot](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app_slot) (resource)
