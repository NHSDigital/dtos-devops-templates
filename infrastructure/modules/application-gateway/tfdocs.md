# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_backend_address_pool"></a> [backend\_address\_pool](#input\_backend\_address\_pool)

Description: A map of backend address pools with either 'ip\_addresses' or 'fqdns' for each target. The key name will be used to retrieve the name from var.names.

Type:

```hcl
map(object({
    ip_addresses = optional(list(string))
    fqdns        = optional(list(string))
  }))
```

### <a name="input_backend_http_settings"></a> [backend\_http\_settings](#input\_backend\_http\_settings)

Description: A map of backend HTTP settings for the Application Gateway. The key name will be used to retrieve the name from var.names.

Type:

```hcl
map(object({
    cookie_based_affinity               = string
    affinity_cookie_name                = optional(string)
    path                                = optional(string)
    port                                = number
    probe_key                           = optional(string) # Since the names map is only interpolated inside the module, we have to pass in the probe key from the root module
    protocol                            = string
    request_timeout                     = optional(number)
    host_name                           = optional(string)
    pick_host_name_from_backend_address = optional(bool)
    trusted_root_certificate_names      = optional(list(string))
    connection_draining = optional(object({
      enabled           = bool
      drain_timeout_sec = number
    }))
  }))
```

### <a name="input_frontend_ip_configuration"></a> [frontend\_ip\_configuration](#input\_frontend\_ip\_configuration)

Description: A map of frontend IP configurations, each with either a public IP or private IP configuration. The key name will be used to retrieve the name from var.names.

Type:

```hcl
map(object({
    public_ip_address_id          = optional(string)
    subnet_id                     = optional(string)
    private_ip_address            = optional(string)
    private_ip_address_allocation = optional(string)
  }))
```

### <a name="input_frontend_port"></a> [frontend\_port](#input\_frontend\_port)

Description: A map of front end port numbers. The key name will be used to retrieve the name from var.names.

Type: `map(number)`

### <a name="input_gateway_subnet"></a> [gateway\_subnet](#input\_gateway\_subnet)

Description: The entire gateway subnet module object.

Type: `any`

### <a name="input_http_listener"></a> [http\_listener](#input\_http\_listener)

Description: A map of HTTP listeners configuration. The key name will be used to retrieve the name from var.names.

Type:

```hcl
map(object({
    host_name                     = optional(string)
    host_names                    = optional(list(string), [])
    firewall_policy_id            = optional(string)
    frontend_ip_configuration_key = string
    frontend_port_key             = string
    protocol                      = string
    require_sni                   = optional(bool, false)
    ssl_certificate_key           = optional(string)
    ssl_profile_name              = optional(string)
  }))
```

### <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id)

Description: n/a

Type: `string`

### <a name="input_location"></a> [location](#input\_location)

Description: location

Type: `string`

### <a name="input_names"></a> [names](#input\_names)

Description: A map containing configuration object names for the Application Gateway.

Type: `any`

### <a name="input_probe"></a> [probe](#input\_probe)

Description: A map of health probes for the Application Gateway. The key name will be used to retrieve the name from var.names.

Type:

```hcl
map(object({
    host                                      = optional(string)
    interval                                  = number
    path                                      = string
    pick_host_name_from_backend_http_settings = optional(bool)
    protocol                                  = string
    timeout                                   = number
    unhealthy_threshold                       = number
    minimum_servers                           = optional(number)
    port                                      = optional(number)
    match = optional(object({
      status_code = list(string)
      body        = optional(string)
    }))
  }))
```

### <a name="input_request_routing_rule"></a> [request\_routing\_rule](#input\_request\_routing\_rule)

Description: A map of request routing rules for the Application Gateway. The key name will be used to retrieve the name from var.names.

Type:

```hcl
map(object({
    backend_address_pool_key  = string
    backend_http_settings_key = string
    http_listener_key         = string
    priority                  = number
    rewrite_rule_set_key      = optional(string)
    rule_type                 = string
  }))
```

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which to create the Application Gateway. Changing this forces a new resource to be created.

Type: `string`

### <a name="input_sku"></a> [sku](#input\_sku)

Description: The SKU of the Application Gateway (Basic, Standard\_v2, or WAF\_v2).

Type: `string`

### <a name="input_ssl_certificate"></a> [ssl\_certificate](#input\_ssl\_certificate)

Description: A map of SSL certificates. Each entry can contain either 'data' (with optional pfx 'password'), or 'key\_vault\_secret\_id'. The key name will be used to retrieve the name from var.names.

Type:

```hcl
map(object({
    data                = optional(string)
    key_vault_secret_id = optional(string)
    password            = optional(string)
  }))
```

### <a name="input_zones"></a> [zones](#input\_zones)

Description: The availability zones which the Application Gateway will span.

Type: `list(string)`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_autoscale_max"></a> [autoscale\_max](#input\_autoscale\_max)

Description: n/a

Type: `number`

Default: `null`

### <a name="input_autoscale_min"></a> [autoscale\_min](#input\_autoscale\_min)

Description: n/a

Type: `number`

Default: `null`

### <a name="input_rewrite_rule_set"></a> [rewrite\_rule\_set](#input\_rewrite\_rule\_set)

Description: A map of request rewrite rules for the Application Gateway. The key name will be used to retrieve the name from var.names.

Type:

```hcl
map(object({
    rewrite_rule = optional(map(object({
      rule_sequence = number
      condition = optional(map(object({
        ignore_case = optional(bool)
        negate      = optional(bool)
        pattern     = string
        variable    = string
      })))
      request_header_configuration  = optional(map(string))
      response_header_configuration = optional(map(string))
      url = optional(object({
        components   = optional(string)
        path         = optional(string)
        query_string = optional(string)
        reroute      = optional(bool)
      }))
    })))
  }))
```

Default: `{}`

### <a name="input_ssl_policy_name"></a> [ssl\_policy\_name](#input\_ssl\_policy\_name)

Description: n/a

Type: `string`

Default: `"AppGwSslPolicy20220101"`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: Resource tags to be applied throughout the deployment.

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id)

Description: n/a
## Resources

The following resources are used by this module:

- [azurerm_application_gateway.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway) (resource)
- [azurerm_key_vault_access_policy.appgw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) (resource)
- [azurerm_user_assigned_identity.appgw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) (resource)
- [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
