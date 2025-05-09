# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description: The location/region where the  Key Vault is created.

Type: `string`

### <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id)

Description: id of the log analytics workspace to send resource logging to via diagnostic settings

Type: `string`

### <a name="input_monitor_diagnostic_setting_keyvault_enabled_logs"></a> [monitor\_diagnostic\_setting\_keyvault\_enabled\_logs](#input\_monitor\_diagnostic\_setting\_keyvault\_enabled\_logs)

Description: Controls what logs will be enabled for the keyvault

Type: `list(string)`

### <a name="input_monitor_diagnostic_setting_keyvault_metrics"></a> [monitor\_diagnostic\_setting\_keyvault\_metrics](#input\_monitor\_diagnostic\_setting\_keyvault\_metrics)

Description: Controls what metrics will be enabled for the keyvault

Type: `list(string)`

### <a name="input_name"></a> [name](#input\_name)

Description: n/a

Type: `string`

### <a name="input_private_endpoint_properties"></a> [private\_endpoint\_properties](#input\_private\_endpoint\_properties)

Description: Consolidated properties for the Key Vault Private Endpoint.

Type:

```hcl
object({
    private_dns_zone_ids_keyvault        = optional(list(string), [])
    private_endpoint_enabled             = optional(bool, false)
    private_endpoint_subnet_id           = optional(string, "")
    private_endpoint_resource_group_name = optional(string, "")
    private_service_connection_is_manual = optional(bool, false)
  })
```

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which to create the Key Vault. Changing this forces a new resource to be created.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_disk_encryption"></a> [disk\_encryption](#input\_disk\_encryption)

Description: Should the disk encryption be enabled

Type: `bool`

Default: `true`

### <a name="input_enable_rbac_authorization"></a> [enable\_rbac\_authorization](#input\_enable\_rbac\_authorization)

Description: n/a

Type: `bool`

Default: `false`

### <a name="input_metric_enabled"></a> [metric\_enabled](#input\_metric\_enabled)

Description: to enable retention for diagnostic settings metric

Type: `bool`

Default: `true`

### <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled)

Description: Controls whether data in the account may be accessed from public networks.

Type: `bool`

Default: `false`

### <a name="input_purge_protection_enabled"></a> [purge\_protection\_enabled](#input\_purge\_protection\_enabled)

Description: Should the purge protection be enabled.

Type: `bool`

Default: `false`

### <a name="input_rbac_roles"></a> [rbac\_roles](#input\_rbac\_roles)

Description: List of RBAC roles to assign to the Key Vault.

Type: `list(string)`

Default: `[]`

### <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name)

Description: Type of the Key Vault's SKU.

Type: `string`

Default: `"standard"`

### <a name="input_soft_delete_retention"></a> [soft\_delete\_retention](#input\_soft\_delete\_retention)

Description: Number of days to retain a deleted vault

Type: `number`

Default: `"7"`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: Resource tags to be applied throughout the deployment.

Type: `map(string)`

Default: `{}`
## Modules

The following Modules are called:

### <a name="module_diagnostic-settings"></a> [diagnostic-settings](#module\_diagnostic-settings)

Source: ../diagnostic-settings

Version:

### <a name="module_private_endpoint_keyvault"></a> [private\_endpoint\_keyvault](#module\_private\_endpoint\_keyvault)

Source: ../private-endpoint

Version:

### <a name="module_rbac_assignments"></a> [rbac\_assignments](#module\_rbac\_assignments)

Source: ../rbac-assignment

Version:
## Outputs

The following outputs are exported:

### <a name="output_key_vault_id"></a> [key\_vault\_id](#output\_key\_vault\_id)

Description: n/a

### <a name="output_key_vault_name"></a> [key\_vault\_name](#output\_key\_vault\_name)

Description: n/a

### <a name="output_key_vault_url"></a> [key\_vault\_url](#output\_key\_vault\_url)

Description: n/a
## Resources

The following resources are used by this module:

- [azurerm_key_vault.keyvault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) (resource)
- [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
