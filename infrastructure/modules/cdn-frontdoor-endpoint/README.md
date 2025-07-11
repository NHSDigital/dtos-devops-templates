# cdn-frontdoor-endpoint

A Terraform module to publish an application or website to the Internet, populating a [Front Door Profile](../cdn-frontdoor-profile/README.md) with the following Front Door configuration resources:
- Endpoint
- Origin Group
- Origins (inc. Private Link connections)
- Custom Domains (inc. DNS records)
- Route
- Security Policies (WAF rule associations)

> ⚠️ Private Link connections need manual approval via Azure Portal until approvals can be automated via the AzureRM API. There can be a substantial latency for the connection request to even appear, and orphaned connections/requests can take multiple hours to be pruned - all of which can be very confusing.

## Features
- Working Custom Domain managed certificates for leaf domains without their own DNS zones. e.g.:
  ```
  host_name     = "www.foo.bar.com"
  dns_zone_name = "bar.com"
  ```
- Apex domains are specified using an identical `host_name` and `dns_zone_name`. Front Door does not automatically renew certificates for apex domains, hence why long-lived customer certificates may be preferred.
- Supports configuring multiple DNS domains in different resource groups.
- Can associate multiple WAF policies in different resource groups.

## Simple Example
```
module "frontdoor_endpoint" {
  source = "../../../dtos-devops-templates/infrastructure/modules/cdn-frontdoor-endpoint"

  providers = {
    azurerm     = azurerm.hub # Each project's Front Door profile (with secrets) resides in Hub since it's shared infra with a Non-live/Live deployment pattern
    azurerm.dns = azurerm.hub
  }

  cdn_frontdoor_profile_id = data.azurerm_cdn_frontdoor_profile.this.id
  custom_domains = {
    www = {
      host_name     = "www.foo.com"
      dns_zone_name    = "foo.com"
      dns_zone_rg_name = "nonlive-dns-records"
    }
  }
  name = "dev-www" # environment-specific to avoid naming collisions within a Front Door Profile
  origins = {
    "dev-uks-www" = {
      hostname           = "dev-uks-www.azurewebsites.net"
      origin_host_header = "dev-uks-www.azurewebsites.net"
    }
  }

  tags = var.tags
}
```

## Complex Example
This example loops a `var.frontdoor` map variable supplied by a `.tfvars` file. The example demonstrates origins in multiple regions, Private Link, a health probe, and a customer managed certificate.

Private Link requires some interpolation before calling the module, to dynamically retrieve the `private_link_target_id` values (Web Apps in this example). Likewise if a "CustomerCertificate" is used.

**example.tfvars**
```hcl
frontdoor_endpoint = {
  webui = {
    origin_group = {
      session_affinity_enabled = true

      health_probe = {
        interval_in_seconds = 20
        path                = "/health"
        request_type        = "GET"
      }
    }

    origin = {
      # Dynamically picks all origins for a specific Web App, adding Private Link connection if enabled (needs manual approval)
      webapp_key                     = "FrontEndUi" # From var.linux_web_app.linux_web_app_config
    }

    custom_domains = {
      foo = {
        host_name        = "foo.com"
        dns_zone_name    = "foo.com"
        dns_zone_rg_name = "nonlive-dns-records"

        tls = {
          certificate_type         = "CustomerCertificate"
          cdn_frontdoor_secret_key = "foo-apex" # From Front Door profile in Hub
        }
      }
    }

    security_policies = {
      MyWafPolicy = {
        associated_domain_keys                = ["foo"] # From custom_domains above. Use "endpoint" for the default domain (if linked in Front Door route).
        cdn_frontdoor_firewall_policy_name    = "mywafpolicy"
        cdn_frontdoor_firewall_policy_rg_name = "nonlive-waf-policies"
      }
    }
  }
}
```

**frontdoor.tf**
```hcl
module "frontdoor_endpoint" {
  source = "../../../dtos-devops-templates/infrastructure/modules/cdn-frontdoor-endpoint"

  for_each = var.frontdoor_endpoint

  providers = {
    azurerm     = azurerm.hub # Each project's Front Door profile (with secrets) resides in Hub since it's shared infra with a Non-live/Live deployment pattern
    azurerm.dns = azurerm.hub
  }

  cdn_frontdoor_profile_id              = data.terraform_remote_state.hub.outputs.frontdoor_profile["dtos-${var.application_full_name}"].id
  custom_domains = {
    for k, v in each.value.custom_domains : k => merge(
      v,
      {
        tls = merge(
          v.tls,
          v.tls.certificate_type == "CustomerCertificate" && v.tls.cdn_frontdoor_secret_key != null ? {
            cdn_frontdoor_secret_id = data.terraform_remote_state.hub.outputs.frontdoor_profile["dtos-${var.application_full_name}"].secrets[v.tls.cdn_frontdoor_secret_key].id
          } : {}
        )
      }
    )
  }
  name         = "${var.environment}-${each.key}"
  origin_group = each.value.origin_group
  origins = {
    for region in keys(var.regions) : module.linux_web_app["${each.value.origin.webapp_key}-${region}"].name => merge(
      each.value.origin,
      {
        hostname           = "${module.linux_web_app["${each.value.origin.webapp_key}-${region}"].name}.azurewebsites.net"
        origin_host_header = "${module.linux_web_app["${each.value.origin.webapp_key}-${region}"].name}.azurewebsites.net"

        private_link = var.features.private_endpoints_enabled ? {
          target_type            = "sites" # "sites" for App Services, "managedEnvironments" for Container Apps.
          location               = region
          private_link_target_id = module.linux_web_app["${each.value.origin.webapp_key}-${region}"].id
        } : null
      }
    )
  }
  route                   = each.value.route
  security_policies       = each.value.security_policies

  tags = var.tags
}

```

**variables.tf** in root module
```hcl
variable "frontdoor_endpoint" {
  description = "Configuration for Front Door"
  type = map(object({
    origin = object({
      enabled                        = optional(bool, true)
      priority                       = optional(number, 1)   # 1–5
      webapp_key                     = string                # From var.linux_web_app.linux_web_app_config
      weight                         = optional(number, 500) # 1–1000
    })

    origin_group = optional(object({
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
    }), {})

    custom_domains = optional(map(object({
      dns_zone_name = string
      host_name     = string

      tls = optional(object({
        certificate_type         = optional(string, "ManagedCertificate")
        cdn_frontdoor_secret_key = optional(string, null) # From var.projects[].frontdoor_profile.secrets in Hub
      }), {})

      zone_rg_name = optional(string, null)
    })), {})

    route = optional(object({
      cache = optional(object({
        query_string_caching_behavior = optional(string, "IgnoreQueryString") # "IgnoreQueryString" etc.
        query_strings                 = optional(list(string))
        compression_enabled           = optional(bool, false)
        content_types_to_compress     = optional(list(string))
      }))

      cdn_frontdoor_origin_path = optional(string, null)
      enabled                   = optional(bool, true)
      forwarding_protocol       = optional(string, "MatchRequest") # "HttpOnly" | "HttpsOnly" | "MatchRequest"
      https_redirect_enabled    = optional(bool, false)
      link_to_default_domain    = optional(bool, false)
      patterns_to_match         = optional(list(string), ["/*"])
      supported_protocols       = optional(list(string), ["Https"])
    }), {})

    security_policies = optional(map(object({
      associated_domain_keys                = list(string)
      cdn_frontdoor_firewall_policy_name    = string
      cdn_frontdoor_firewall_policy_rg_name = optional(string, null)
    })), {})
  }))
}
```

## Terraform documentation
For the list of inputs, outputs, resources... check the [terraform module documentation](tfdocs.md).
