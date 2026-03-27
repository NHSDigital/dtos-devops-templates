# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description: Azure region in which to create the Logic App.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: Name of the Logic App workflow.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: Resource group in which to create the Logic App.

Type: `string`

### <a name="input_slack_webhook_url"></a> [slack\_webhook\_url](#input\_slack\_webhook\_url)

Description: Slack incoming webhook URL. Stored as a SecureString workflow parameter.

Type: `string`

## Outputs

The following outputs are exported:

### <a name="output_trigger_callback_url"></a> [trigger\_callback\_url](#output\_trigger\_callback\_url)

Description: HTTP trigger callback URL to register with an Azure Monitor action group webhook receiver.
## Resources

The following resources are used by this module:

- [azurerm_logic_app_action_custom.post_to_slack](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/logic_app_action_custom) (resource)
- [azurerm_logic_app_trigger_http_request.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/logic_app_trigger_http_request) (resource)
- [azurerm_logic_app_workflow.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/logic_app_workflow) (resource)
