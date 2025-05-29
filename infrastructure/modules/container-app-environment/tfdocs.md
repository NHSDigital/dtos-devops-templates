# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id)

Description: ID of the log analytics workspace to send resource logging to via diagnostic settings

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: Name of the container app environment.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: Name of the resource group to create the container app environment in.

Type: `string`

### <a name="input_vnet_integration_subnet_id"></a> [vnet\_integration\_subnet\_id](#input\_vnet\_integration\_subnet\_id)

Description: ID of the subnet for the container app environment. Must be at least /23

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_location"></a> [location](#input\_location)

Description: The location/region where the container app environment is created.

Type: `string`

Default: `"UK South"`

<<<<<<< HEAD
### <a name="input_private_dns_zone_rg_name"></a> [private\_dns\_zone\_rg\_name](#input\_private\_dns\_zone\_rg\_name)

Description: Name of the hub resource group where the private DNS zone is located. This is only required if adding custom DNS records.

Type: `string`

Default: `null`

=======
>>>>>>> 21b774d (Update terraform docs (#181))
### <a name="input_zone_redundancy_enabled"></a> [zone\_redundancy\_enabled](#input\_zone\_redundancy\_enabled)

Description: Enable availability zone redundancy for the container app environment. Should be set to true in production.

Type: `bool`

Default: `false`
## Modules

The following Modules are called:

### <a name="module_apex-record"></a> [apex-record](#module\_apex-record)

Source: ../private-dns-a-record

Version:

### <a name="module_wildcard-record"></a> [wildcard-record](#module\_wildcard-record)

Source: ../private-dns-a-record

Version:
## Outputs

The following outputs are exported:

### <a name="output_default_domain"></a> [default\_domain](#output\_default\_domain)

Description: Default internal DNS domain. Should be registered in the private DNS zone.

### <a name="output_id"></a> [id](#output\_id)

Description: Container app environment ID
## Resources

The following resources are used by this module:

- [azurerm_container_app_environment.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment) (resource)
