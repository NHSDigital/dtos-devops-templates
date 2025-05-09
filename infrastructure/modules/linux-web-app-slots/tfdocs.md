# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_linux_web_app_id"></a> [linux\_web\_app\_id](#input\_linux\_web\_app\_id)

Description: The ID of the Linux Web App.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: The function app slot name.

Type: `string`

### <a name="input_share_name"></a> [share\_name](#input\_share\_name)

Description: The name which should be used for this Storage Account.

Type: `string`

### <a name="input_storage_account_access_key"></a> [storage\_account\_access\_key](#input\_storage\_account\_access\_key)

Description: The Storage Account Primary Access Key.

Type: `string`

### <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name)

Description: The name of the Storage Account.

Type: `string`

### <a name="input_storage_name"></a> [storage\_name](#input\_storage\_name)

Description: The name of the Storage Account.

Type: `string`

### <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type)

Description: The Azure Storage Type. Possible values include AzureFiles and AzureBlob

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_linux_web_app_slots_enabled"></a> [linux\_web\_app\_slots\_enabled](#input\_linux\_web\_app\_slots\_enabled)

Description: If slots are enabled or not.

Type: `bool`

Default: `false`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: Resource tags to be applied throughout the deployment.

Type: `map(string)`

Default: `{}`


## Resources

The following resources are used by this module:

- [azurerm_linux_web_app_slot.linux_web_app_slots](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app_slot) (resource)
