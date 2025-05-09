# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_azurerm_eventgrid_id"></a> [azurerm\_eventgrid\_id](#input\_azurerm\_eventgrid\_id)

Description: The azurerm Event Grid id to link to.

Type: `string`

### <a name="input_dead_letter_storage_account_container_name"></a> [dead\_letter\_storage\_account\_container\_name](#input\_dead\_letter\_storage\_account\_container\_name)

Description: The name of storage account container for the Dead Letter queue.

Type: `string`

### <a name="input_dead_letter_storage_account_id"></a> [dead\_letter\_storage\_account\_id](#input\_dead\_letter\_storage\_account\_id)

Description: The name of storage account container id for the Dead Letter queue.

Type: `string`

### <a name="input_function_endpoint"></a> [function\_endpoint](#input\_function\_endpoint)

Description: The function endpoint value

Type: `string`

### <a name="input_principal_id"></a> [principal\_id](#input\_principal\_id)

Description: The principal id of the function app.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which to create the Event Grid. Changing this forces a new resource to be created.

Type: `string`

### <a name="input_subscription_name"></a> [subscription\_name](#input\_subscription\_name)

Description: The name of the Event Grid event subscription.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_tags"></a> [tags](#input\_tags)

Description: A mapping of tags to assign to the Event Grid topic.

Type: `map(string)`

Default: `{}`


## Resources

The following resources are used by this module:

- [azurerm_eventgrid_event_subscription.eventgrid_event_subscription](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventgrid_event_subscription) (resource)
- [azurerm_role_assignment.eventgrid_subscription_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
