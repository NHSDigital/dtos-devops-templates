# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the Azure Relay Hybrid Connection.

Type: `string`

### <a name="input_relay_namespace_name"></a> [relay\_namespace\_name](#input\_relay\_namespace\_name)

Description: The name of the Azure Relay namespace in which to create the Hybrid Connection.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group containing the Azure Relay namespace.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_authorization_rules"></a> [authorization\_rules](#input\_authorization\_rules)

Description: A map of authorization rules to create for the Hybrid Connection.

Type:

```hcl
map(object({
    listen = optional(bool, false)
    send   = optional(bool, false)
    manage = optional(bool, false)
  }))
```

Default: `{}`

### <a name="input_requires_client_authorization"></a> [requires\_client\_authorization](#input\_requires\_client\_authorization)

Description: Whether client authorization is required for this Hybrid Connection.

Type: `bool`

Default: `true`

### <a name="input_user_metadata"></a> [user\_metadata](#input\_user\_metadata)

Description: User metadata string for the Hybrid Connection.

Type: `string`

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_authorization_rule_ids"></a> [authorization\_rule\_ids](#output\_authorization\_rule\_ids)

Description: A map of authorization rule names to their IDs.

### <a name="output_authorization_rule_primary_connection_strings"></a> [authorization\_rule\_primary\_connection\_strings](#output\_authorization\_rule\_primary\_connection\_strings)

Description: A map of authorization rule names to their primary connection strings.

### <a name="output_authorization_rule_primary_keys"></a> [authorization\_rule\_primary\_keys](#output\_authorization\_rule\_primary\_keys)

Description: A map of authorization rule names to their primary keys.

### <a name="output_authorization_rule_secondary_connection_strings"></a> [authorization\_rule\_secondary\_connection\_strings](#output\_authorization\_rule\_secondary\_connection\_strings)

Description: A map of authorization rule names to their secondary connection strings.

### <a name="output_authorization_rule_secondary_keys"></a> [authorization\_rule\_secondary\_keys](#output\_authorization\_rule\_secondary\_keys)

Description: A map of authorization rule names to their secondary keys.

### <a name="output_id"></a> [id](#output\_id)

Description: The ID of the Relay Hybrid Connection.

### <a name="output_name"></a> [name](#output\_name)

Description: The name of the Relay Hybrid Connection.
## Resources

The following resources are used by this module:

- [azurerm_relay_hybrid_connection.hybrid_connection](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/relay_hybrid_connection) (resource)
- [azurerm_relay_hybrid_connection_authorization_rule.auth_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/relay_hybrid_connection_authorization_rule) (resource)
