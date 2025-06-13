# cdn-frontdoor

A Terraform module to populate a [Front Door Profile](../cdn-frontdoor-profile/README.md) with the following Front Door configuration resources, feature complete:
- Endpoint
- Origin Group
- Origins (inc. Private Link connections)
- Custom Domains (inc. DNS records)
- Route
- Security Policies (WAF rule associations)

Rule Sets are defined via a separate [cdn-frontdoor-ruleset](../cdn-frontdoor-ruleset/README.md) module since their intention may vary. Some generic rules may be intended for all endpoints in a Profile (deployed with a Profile), but some rules are intended for a specific route.

> ⚠️ Private Link connections need manual approval via Azure Portal until approvals can be automated via the AzureRM API. There can be a substantial latency for the connection request to even appear, and orphaned connections/requests can take multiple hours to be pruned - all of which can be very confusing.

## Features
- Working Custom Domain managed certificates for leaf domains without their own DNS zones. e.g.:
  ```
  host_name     = "www.foo.bar.com"
  dns_zone_name = "bar.com"
  ```
- Apex domains are specified using an identical `host_name` and `dns_zone_name` (requires a "CustomerCertificate").
- Supports configuring multiple DNS domains in different resource groups.
- Can associate multiple WAF policies in different resource groups.

## Example Usage

Configuration with Private Link requires some interpolation before calling the module, to dynamically retrieve the `private_link_target_id` values (Web Apps in this example). Likewise if a "CustomerCertificate" is used.

**example.tfvars**
```hcl
frontdoor = {
  www = {
    origin = {
      # Dynamically picks all origins for a specific Web App, adding Private Link connection if enabled (needs manual approval)
      webapp_key                     = "FrontEndUi" # From var.linux_web_app.linux_web_app_config
      certificate_name_check_enabled = true # Required for Private Link
    }
    custom_domains = {
      frontend = {
        host_name     = "frontend.foo.com"
        dns_zone_name = "foo.com"
      }
      apex = {
        host_name     = "bar.com"
        dns_zone_name = "bar.com"

        tls = {
          certificate_type         = "CustomerCertificate"
          cdn_frontdoor_secret_key = "bar-apex" # From Front Door profile in Hub
        }
      }
    }
    route = {
      link_to_default_domain = false
    }
    security_policies = {
      MyWafPolicy = {
        cdn_frontdoor_firewall_policy_name = "mywafpolicy"
        associated_domain_keys             = ["frontend", "apex"] # From custom_domains above. Use "endpoint" for the default domain (if linked in Front Door route).
      }
    }
  }
}
```

**frontdoor.tf**
```hcl
module "frontdoor" {
  source = "../../../dtos-devops-templates/infrastructure/modules/cdn-frontdoor"

  for_each = var.frontdoor

  providers = {
    azurerm     = azurerm.hub # Each project's Front Door profile (with secrets) resides in Hub since it's shared infra with a Non-live/Live deployment pattern
    azurerm.dns = azurerm.hub
  }

  cdn_frontdoor_firewall_policy_rg_name = data.terraform_remote_state.hub.outputs.networking_rg_name[local.primary_region]
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
  endpoint             = each.value.endpoint
  environment          = var.environment
  frontdoor_naming_key = each.key
  origin_group         = each.value.origin_group
  origins = {
    for region in keys(var.regions) : module.linux_web_app["${each.value.origin.webapp_key}-${region}"].name => merge(
      each.value.origin,
      {
        hostname           = "${module.linux_web_app["${each.value.origin.webapp_key}-${region}"].name}.azurewebsites.net"
        origin_host_header = "${module.linux_web_app["${each.value.origin.webapp_key}-${region}"].name}.azurewebsites.net"
        private_link = var.features.private_endpoints_enabled ? {
          target_type            = "sites"
          location               = region
          private_link_target_id = module.linux_web_app["${each.value.origin.webapp_key}-${region}"].id
        } : null
      }
    )
  }
  public_dns_zone_rg_name = data.terraform_remote_state.hub.outputs.public_dns_zone_rg_name
  resource_group_name     = data.terraform_remote_state.hub.outputs.project_rg_names["dtos-${var.application_full_name}-${local.primary_region}"]
  route                   = each.value.route
  security_policies       = each.value.security_policies

  tags = var.tags
}

```

**variables.tf** in root module
```hcl
variable "frontdoor" {
  description = "Configuration for Front Door"
  type = map(object({
    endpoint = optional(object({
      enabled = optional(bool, true)
    }), {})

    origin = object({
      certificate_name_check_enabled = bool # must be true for Private Link
      enabled                        = optional(bool, true)
      http_port                      = optional(number, 80)  # 1–65535
      https_port                     = optional(number, 443) # 1–65535
      priority                       = optional(number, 1)   # 1–5
      webapp_key                     = string                # From var.linux_web_app.linux_web_app_config
      weight                         = optional(number, 500) # 1–1000
    })

    origin_group = optional(object({
      health_probe = optional(object({
        protocol            = string                   # Required: "Http" or "Https"
        interval_in_seconds = number                   # Required: 1–255
        request_type        = optional(string, "HEAD") # Optional: "GET" or "HEAD"
        path                = optional(string, "/")    # Optional
      }))

      load_balancing = optional(object({
        additional_latency_in_milliseconds = optional(number, 50) # Optional: 0–1000
        sample_size                        = optional(number, 4)  # Optional: 0–255
        successful_samples_required        = optional(number, 3)  # Optional: 0–255
      }), {})

      session_affinity_enabled                                  = optional(bool, true)
      restore_traffic_time_to_healed_or_new_endpoint_in_minutes = optional(number)
    }), {})

    custom_domains = map(object({
      dns_zone_name = string
      host_name     = string

      tls = optional(object({
        certificate_type         = optional(string, "ManagedCertificate") # Use of apex domain as a hostname requires "CustomerCertificate"
        cdn_frontdoor_secret_key = optional(string, null)                 # From var.projects[].frontdoor_profile.secrets in Hub
      }), {})

      zone_rg_name = optional(string, null)
    }))

    route = object({
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
      link_to_default_domain    = optional(bool, true)
      patterns_to_match         = optional(list(string), ["/*"])
      supported_protocols       = optional(list(string), ["Https"])
    })

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
