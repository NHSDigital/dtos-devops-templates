# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_cdn_frontdoor_profile_id"></a> [cdn\_frontdoor\_profile\_id](#input\_cdn\_frontdoor\_profile\_id)

Description: ID of the Front Door profile to associate endpoints and origin groups with

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: Name, which will be used as a prefix for most of the configuration elements. If multiple environments will cohabit with the Front Door Profile, ensure there is an environment component to this name to avoid naming collisions.

Type: `string`

### <a name="input_origins"></a> [origins](#input\_origins)

Description: Map of Front Door Origin configurations. If 'origin\_host\_header' is omitted, the connection to the target will use the host header from the original request.

Type:

```hcl
map(object({
    enabled            = optional(bool, true)
    hostname           = string
    origin_host_header = optional(string)    # if omitted, the connection to the target will use the host header from the original request
    priority           = optional(number, 1) # 1–5

    private_link = optional(object({
      location               = string
      private_link_target_id = string
      target_type            = optional(string) # blob, blob_secondary, Gateway, managedEnvironments (Container Apps), sites (App Services), web and web_secondary
    }))

    weight = optional(number, 500) # 1–1000
  }))
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_custom_domains"></a> [custom\_domains](#input\_custom\_domains)

Description: Map of Front Door Custom Domain configurations

Type:

```hcl
map(object({
    dns_zone_name    = string
    dns_zone_rg_name = string
    host_name        = string

    tls = optional(object({
      # https://learn.microsoft.com/en-us/azure/frontdoor/standard-premium/how-to-configure-https-custom-domain?tabs=powershell#register-azure-front-door
      certificate_type        = optional(string, "ManagedCertificate") # Use of apex domain as a hostname requires "CustomerCertificate"
      cdn_frontdoor_secret_id = optional(string, null)
    }), {})
  }))
```

Default: `{}`

### <a name="input_origin_group"></a> [origin\_group](#input\_origin\_group)

Description: Front Door Origin Group configuration

Type:

```hcl
object({
    health_probe = optional(object({
      interval_in_seconds = number # Required: 1–255
      path                = optional(string, "/")
      protocol            = optional(string, "Https")
      request_type        = optional(string, "HEAD")
    }))

    load_balancing = optional(object({
      additional_latency_in_milliseconds = optional(number, 50) # Optional: 0–1000
      sample_size                        = optional(number, 4)  # Optional: 0–255
      successful_samples_required        = optional(number, 3)  # Optional: 0–255
    }), {})

    session_affinity_enabled                                  = optional(bool, true)
    restore_traffic_time_to_healed_or_new_endpoint_in_minutes = optional(number)
  })
```

Default: `{}`

### <a name="input_route"></a> [route](#input\_route)

Description: Map of Front Door route configurations

Type:

```hcl
object({
    cache = optional(object({
      compression_enabled           = optional(bool, false)
      content_types_to_compress     = optional(list(string))
      query_string_caching_behavior = optional(string, "IgnoreQueryString") # "IgnoreQueryString" etc.
      query_strings                 = optional(list(string))
    }))

    cdn_frontdoor_origin_path  = optional(string, null)
    cdn_frontdoor_rule_set_ids = optional(list(string))
    enabled                    = optional(bool, true)
    forwarding_protocol        = optional(string, "MatchRequest") # "HttpOnly" | "HttpsOnly" | "MatchRequest"
    https_redirect_enabled     = optional(bool, false)
    link_to_default_domain     = optional(bool, false)
    patterns_to_match          = optional(list(string), ["/*"])
    supported_protocols        = optional(list(string), ["Https"]) # Must be a subset of ["Http", "Https"]
  })
```

Default: `{}`

### <a name="input_security_policies"></a> [security\_policies](#input\_security\_policies)

Description: Optional map of security policies to apply. Each must include the WAF policy and domain associations

Type:

```hcl
map(object({
    associated_domain_keys                = list(string) # From var.custom_domains above, use "endpoint" for the default domain
    cdn_frontdoor_firewall_policy_id      = optional(string, null) # Pass ID directly to avoid data source lookup when policy is created in the same apply
    cdn_frontdoor_firewall_policy_name    = optional(string, null)
    cdn_frontdoor_firewall_policy_rg_name = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: Resource tags to be applied throughout the deployment

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_custom_domains"></a> [custom\_domains](#output\_custom\_domains)

Description: n/a

### <a name="output_endpoint"></a> [endpoint](#output\_endpoint)

Description: n/a

### <a name="output_origin_group"></a> [origin\_group](#output\_origin\_group)

Description: n/a

### <a name="output_origins"></a> [origins](#output\_origins)

Description: n/a

### <a name="output_route"></a> [route](#output\_route)

Description: n/a

### <a name="output_security_policy"></a> [security\_policy](#output\_security\_policy)

Description: n/a
## Resources

The following resources are used by this module:

- [azurerm_cdn_frontdoor_custom_domain.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_custom_domain) (resource)
- [azurerm_cdn_frontdoor_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_endpoint) (resource)
- [azurerm_cdn_frontdoor_origin.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_origin) (resource)
- [azurerm_cdn_frontdoor_origin_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_origin_group) (resource)
- [azurerm_cdn_frontdoor_route.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_route) (resource)
- [azurerm_cdn_frontdoor_security_policy.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_security_policy) (resource)
- [azurerm_dns_a_record.root_alias](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_a_record) (resource)
- [azurerm_dns_cname_record.custom](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_cname_record) (resource)
- [azurerm_dns_txt_record.challenge](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_txt_record) (resource)
- [azurerm_cdn_frontdoor_firewall_policy.waf](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/cdn_frontdoor_firewall_policy) (data source)
- [azurerm_dns_zone.custom](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/dns_zone) (data source)
