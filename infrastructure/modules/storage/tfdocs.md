# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_containers"></a> [containers](#input\_containers)

Description: Definition of Storage Containers configuration

Type:

```hcl
map(object({
    container_name        = string
    container_access_type = string
  }))
```

### <a name="input_location"></a> [location](#input\_location)

Description: The location/region where the Storage Account is created.

Type: `string`

### <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id)

Description: id of the log analytics workspace to send resource logging to via diagnostic settings

Type: `string`

### <a name="input_monitor_diagnostic_setting_storage_account_enabled_logs"></a> [monitor\_diagnostic\_setting\_storage\_account\_enabled\_logs](#input\_monitor\_diagnostic\_setting\_storage\_account\_enabled\_logs)

Description: Controls what logs will be enabled for the storage

Type: `list(string)`

### <a name="input_monitor_diagnostic_setting_storage_account_metrics"></a> [monitor\_diagnostic\_setting\_storage\_account\_metrics](#input\_monitor\_diagnostic\_setting\_storage\_account\_metrics)

Description: Controls what metrics will be enabled for the storage

Type: `list(string)`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the Storage Account

Type: `string`

### <a name="input_private_endpoint_properties"></a> [private\_endpoint\_properties](#input\_private\_endpoint\_properties)

Description: Consolidated properties for the Function App Private Endpoint.

Type:

```hcl
object({
    private_dns_zone_ids_blob            = optional(list(string), [])
    private_dns_zone_ids_table           = optional(list(string), [])
    private_dns_zone_ids_queue           = optional(list(string), [])
    private_endpoint_enabled             = optional(bool, false)
    private_endpoint_subnet_id           = optional(string, "")
    private_endpoint_resource_group_name = optional(string, "")
    private_service_connection_is_manual = optional(bool, false)
  })
```

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which to create the Storage Account. Changing this forces a new resource to be created.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_account_replication_type"></a> [account\_replication\_type](#input\_account\_replication\_type)

Description: The type of replication to use for this Storage Account. Can be either LRS, GRS, RAGRS or ZRS.

Type: `string`

Default: `"LRS"`

### <a name="input_account_tier"></a> [account\_tier](#input\_account\_tier)

Description: Defines the Tier to use for this storage account. Valid options are Standard and Premium.

Type: `string`

Default: `"Standard"`

### <a name="input_blob_properties_delete_retention_policy"></a> [blob\_properties\_delete\_retention\_policy](#input\_blob\_properties\_delete\_retention\_policy)

Description: The value set for blob properties delete retention policy.

Type: `number`

Default: `null`

### <a name="input_blob_properties_versioning_enabled"></a> [blob\_properties\_versioning\_enabled](#input\_blob\_properties\_versioning\_enabled)

Description: To enable versioning for blob.

Type: `bool`

Default: `false`

### <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled)

Description: Controls whether data in the account may be accessed from public networks.

Type: `bool`

Default: `false`

### <a name="input_queues"></a> [queues](#input\_queues)

Description: List of Storage Queues to create.

Type: `list(string)`

Default: `[]`

### <a name="input_rbac_roles"></a> [rbac\_roles](#input\_rbac\_roles)

Description: List of RBAC roles to assign to the Storage Account.

Type: `list(string)`

Default: `[]`

### <a name="input_storage_account_service"></a> [storage\_account\_service](#input\_storage\_account\_service)

Description: n/a

Type: `set(string)`

Default:

```json
[
  "blobServices",
  "queueServices",
  "tableServices",
  "fileServices"
]
```

### <a name="input_tags"></a> [tags](#input\_tags)

Description: Resource tags to be applied throughout the deployment.

Type: `map(string)`

Default: `{}`
## Modules

The following Modules are called:

### <a name="module_diagnostic-settings"></a> [diagnostic-settings](#module\_diagnostic-settings)

Source: ../diagnostic-settings

Version:

### <a name="module_private_endpoint_blob_storage"></a> [private\_endpoint\_blob\_storage](#module\_private\_endpoint\_blob\_storage)

Source: ../private-endpoint

Version:

### <a name="module_private_endpoint_queue_storage"></a> [private\_endpoint\_queue\_storage](#module\_private\_endpoint\_queue\_storage)

Source: ../private-endpoint

Version:

### <a name="module_private_endpoint_table_storage"></a> [private\_endpoint\_table\_storage](#module\_private\_endpoint\_table\_storage)

Source: ../private-endpoint

Version:

### <a name="module_rbac_assignments"></a> [rbac\_assignments](#module\_rbac\_assignments)

Source: ../rbac-assignment

Version:
## Outputs

The following outputs are exported:

### <a name="output_primary_blob_endpoint_name"></a> [primary\_blob\_endpoint\_name](#output\_primary\_blob\_endpoint\_name)

Description: Name of blob storage endpoint

### <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id)

Description: The ID of the created Storage Account

### <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name)

Description: The name of the created Storage Account

### <a name="output_storage_account_primary_access_key"></a> [storage\_account\_primary\_access\_key](#output\_storage\_account\_primary\_access\_key)

Description: n/a

### <a name="output_storage_account_primary_connection_string"></a> [storage\_account\_primary\_connection\_string](#output\_storage\_account\_primary\_connection\_string)

Description: n/a

### <a name="output_storage_containers"></a> [storage\_containers](#output\_storage\_containers)

Description: n/a
## Resources

The following resources are used by this module:

- [azurerm_storage_account.storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) (resource)
- [azurerm_storage_container.container](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) (resource)
- [azurerm_storage_queue.queue](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_queue) (resource)
- [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
