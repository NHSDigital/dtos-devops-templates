# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_function_app_principal_id"></a> [function\_app\_principal\_id](#input\_function\_app\_principal\_id)

Description: The principal ID (object ID) of the Function App's managed identity.

Type: `string`

### <a name="input_namespace_name"></a> [namespace\_name](#input\_namespace\_name)

Description: The name of the Service Bus namespace.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group containing the Service Bus namespace.

Type: `string`

### <a name="input_service_bus_namespace_id"></a> [service\_bus\_namespace\_id](#input\_service\_bus\_namespace\_id)

Description: The ID of the Service Bus namespace resource for role assignment scope.

Type: `string`

### <a name="input_subscription_name"></a> [subscription\_name](#input\_subscription\_name)

Description: The name of the Service Bus subscription.

Type: `string`

### <a name="input_topic_name"></a> [topic\_name](#input\_topic\_name)

Description: The name of the Service Bus topic.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_max_delivery_count"></a> [max\_delivery\_count](#input\_max\_delivery\_count)

Description: The maximum delivery count of a message before it is dead-lettered.

Type: `number`

Default: `10`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: A map of tags to assign to the subscription.

Type: `map(string)`

Default: `{}`


## Resources

The following resources are used by this module:

- [azurerm_role_assignment.sb_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_servicebus_subscription.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_subscription) (resource)
