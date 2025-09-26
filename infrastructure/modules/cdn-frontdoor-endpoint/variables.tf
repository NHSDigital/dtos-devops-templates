variable "cdn_frontdoor_profile_id" {
  description = "ID of the Front Door profile to associate endpoints and origin groups with"
  type        = string
}

variable "custom_domains" {
  description = "Map of Front Door Custom Domain configurations"
  type = map(object({
    dns_zone_name    = string
    dns_zone_rg_name = string
    host_name        = string

    tls = optional(object({
      # https://learn.microsoft.com/en-us/azure/frontdoor/standard-premium/how-to-configure-https-custom-domain?tabs=powershell#register-azure-front-door
      certificate_type        = optional(string, "ManagedCertificate") # Use of apex domain as a hostname requires "CustomerCertificate"
      cdn_frontdoor_secret_id = optional(string, null)
    }), {})
  }))
  default = {}
}

variable "name" {
  description = "Name, which will be used as a prefix for most of the configuration elements. If multiple environments will cohabit with the Front Door Profile, ensure there is an environment component to this name to avoid naming collisions."
  type        = string
}

variable "origins" {
  description = "Map of Front Door Origin configurations. If 'origin_host_header' is omitted, the connection to the target will use the host header from the original request."
  type = map(object({
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
}

variable "origin_group" {
  description = "Front Door Origin Group configuration"
  type = object({
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
  default = {}
}

variable "route" {
  description = "Map of Front Door route configurations"
  type = object({
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
  default = {}
}

variable "security_policies" {
  description = "Optional map of security policies to apply. Each must include the WAF policy and domain associations"
  type = map(object({
    associated_domain_keys                = list(string) # From var.custom_domains above, use "endpoint" for the default domain
    cdn_frontdoor_firewall_policy_name    = string
    cdn_frontdoor_firewall_policy_rg_name = string
  }))
  default = {}
}

variable "tags" {
  type        = map(string)
  description = "Resource tags to be applied throughout the deployment"
  default     = {}
}
