# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_client_id"></a> [client\_id](#input\_client\_id)

Description: The client ID for the API Management AAD Identity Provider.

Type: `string`

### <a name="input_client_secret"></a> [client\_secret](#input\_client\_secret)

Description: The client secret for the API Management AAD Identity Provider.

Type: `string`

### <a name="input_location"></a> [location](#input\_location)

Description: The location/region where the API Management service should be created.

Type: `string`

### <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id)

Description: id of the log analytics workspace to send resource logging to via diagnostic settings

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the API Management service.

Type: `string`

### <a name="input_publisher_email"></a> [publisher\_email](#input\_publisher\_email)

Description: The email address of the publisher of the API Management service.

Type: `string`

### <a name="input_publisher_name"></a> [publisher\_name](#input\_publisher\_name)

Description: The name of the publisher of the API Management service.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which the API Management service should be created.

Type: `string`

### <a name="input_sku_capacity"></a> [sku\_capacity](#input\_sku\_capacity)

Description: The capacity of the SKU of the API Management service.

Type: `number`

### <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name)

Description: The name of the SKU of the API Management service.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_additional_locations"></a> [additional\_locations](#input\_additional\_locations)

Description: A list of additional locations where the API Management service should be created.

Type:

```hcl
list(object({
    location             = string
    capacity             = number
    zones                = list(number)
    public_ip_address_id = string
    virtual_network_configuration = list(object({
      subnet_id = string
    }))
  }))
```

Default: `[]`

### <a name="input_allowed_tenants"></a> [allowed\_tenants](#input\_allowed\_tenants)

Description: A list of allowed tenants for the API Management AAD Identity Provider.

Type: `list(string)`

Default: `[]`

### <a name="input_certificate_details"></a> [certificate\_details](#input\_certificate\_details)

Description: A list of certificates to upload to the API Management service.

Type:

```hcl
list(object({
    encoded_certificate  = string
    store_name           = string
    certificate_password = string
  }))
```

Default: `[]`

### <a name="input_client_library"></a> [client\_library](#input\_client\_library)

Description: The client library for the API Management AAD Identity Provider.

Type: `string`

Default: `"MSAL-2"`

### <a name="input_custom_domains_developer_portal"></a> [custom\_domains\_developer\_portal](#input\_custom\_domains\_developer\_portal)

Description: List of Custom Domains configurations for the Developer Portal endpoint.

Type:

```hcl
list(object({
    host_name                    = string
    key_vault_id                 = optional(string)
    certificate                  = optional(string)
    certificate_password         = optional(string)
    negotiate_client_certificate = optional(bool, false)
  }))
```

Default: `[]`

### <a name="input_custom_domains_gateway"></a> [custom\_domains\_gateway](#input\_custom\_domains\_gateway)

Description: List of Custom Domains configurations for the Gateway endpoint.

Type:

```hcl
list(object({
    host_name                    = string
    default_ssl_binding          = optional(bool, false)
    key_vault_id                 = optional(string)
    certificate                  = optional(string)
    certificate_password         = optional(string)
    negotiate_client_certificate = optional(bool, false)
  }))
```

Default: `[]`

### <a name="input_custom_domains_management"></a> [custom\_domains\_management](#input\_custom\_domains\_management)

Description: List of Custom Domains configurationd for the Management endpoint.

Type:

```hcl
list(object({
    host_name                    = string
    key_vault_id                 = optional(string)
    certificate                  = optional(string)
    certificate_password         = optional(string)
    negotiate_client_certificate = optional(bool, false)
  }))
```

Default: `[]`

### <a name="input_custom_domains_scm"></a> [custom\_domains\_scm](#input\_custom\_domains\_scm)

Description: List of Custom Domains configurations for the SCM endpoint.

Type:

```hcl
list(object({
    host_name                    = string
    key_vault_id                 = optional(string)
    certificate                  = optional(string)
    certificate_password         = optional(string)
    negotiate_client_certificate = optional(bool, false)
  }))
```

Default: `[]`

### <a name="input_gateway_disabled"></a> [gateway\_disabled](#input\_gateway\_disabled)

Description: Specifies whether the gateway is disabled.

Type: `bool`

Default: `false`

### <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids)

Description: The identity IDs for the API Management service.

Type: `list(string)`

Default: `[]`

### <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type)

Description: The type of identity for the API Management service.

Type: `string`

Default: `"SystemAssigned"`

### <a name="input_metric_enabled"></a> [metric\_enabled](#input\_metric\_enabled)

Description: to enable retention for diagnostic settings metric

Type: `bool`

Default: `false`

### <a name="input_min_api_version"></a> [min\_api\_version](#input\_min\_api\_version)

Description: Controls what logs will be enabled for apim

Type: `string`

Default: `"2021-08-01"`

### <a name="input_monitor_diagnostic_setting_apim_enabled_logs"></a> [monitor\_diagnostic\_setting\_apim\_enabled\_logs](#input\_monitor\_diagnostic\_setting\_apim\_enabled\_logs)

Description: Controls what logs will be enabled for apim

Type: `list(string)`

Default: `null`

### <a name="input_monitor_diagnostic_setting_apim_metrics"></a> [monitor\_diagnostic\_setting\_apim\_metrics](#input\_monitor\_diagnostic\_setting\_apim\_metrics)

Description: Controls what metrics will be enabled for apim

Type: `list(string)`

Default: `null`

### <a name="input_public_ip_address_id"></a> [public\_ip\_address\_id](#input\_public\_ip\_address\_id)

Description: The ID of the public IP address to associate with the API Management service.

Type: `string`

Default: `null`

### <a name="input_sign_in_enabled"></a> [sign\_in\_enabled](#input\_sign\_in\_enabled)

Description: Should anonymous users be redirected to the sign in page?

Type: `bool`

Default: `false`

### <a name="input_sign_up_enabled"></a> [sign\_up\_enabled](#input\_sign\_up\_enabled)

Description: Can users sign up on the development portal?

Type: `bool`

Default: `false`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: A mapping of tags to assign to the API Management service.

Type: `map(string)`

Default: `{}`

### <a name="input_terms_of_service_configuration"></a> [terms\_of\_service\_configuration](#input\_terms\_of\_service\_configuration)

Description: Terms of service configurations.

Type:

```hcl
list(object({
    consent_required = optional(bool, false)
    enabled          = optional(bool, false)
    text             = optional(string, "")
  }))
```

Default: `[]`

### <a name="input_virtual_network_configuration"></a> [virtual\_network\_configuration](#input\_virtual\_network\_configuration)

Description: The virtual network configuration for the API Management service.

Type: `list(string)`

Default: `null`

### <a name="input_virtual_network_type"></a> [virtual\_network\_type](#input\_virtual\_network\_type)

Description: The type of virtual network configuration for the API Management service.

Type: `string`

Default: `"Internal"`

### <a name="input_zones"></a> [zones](#input\_zones)

Description: A list of availability zones where the API Management service should be created.

Type: `list(number)`

Default: `[]`
## Modules

The following Modules are called:

### <a name="module_diagnostic-settings"></a> [diagnostic-settings](#module\_diagnostic-settings)

Source: ../diagnostic-settings

Version:
## Outputs

The following outputs are exported:

### <a name="output_name"></a> [name](#output\_name)

Description: The name of the API Management service.

### <a name="output_private_ip_addresses"></a> [private\_ip\_addresses](#output\_private\_ip\_addresses)

Description: The private IP address of the API Management service.

### <a name="output_system_assigned_identity"></a> [system\_assigned\_identity](#output\_system\_assigned\_identity)

Description: The system-assigned identity of the API Management service.
## Resources

The following resources are used by this module:

- [azurerm_api_management.apim](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management) (resource)
- [azurerm_api_management_custom_domain.apim](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_custom_domain) (resource)
- [azurerm_api_management_identity_provider_aad.apim](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_identity_provider_aad) (resource)
