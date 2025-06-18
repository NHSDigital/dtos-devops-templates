variable "cdn_frontdoor_profile_id" {
  description = "ID of the Front Door profile to associate endpoints and origin groups with"
  type        = string
}

variable "endpoint" {
  description = "Map of Front Door Endpoint configurations"
  type = map(object({
    enabled = optional(bool, true)
  }))
}

variable "origin" {
  description = "Map of Front Door Origin configurations"
  type = map(object({
    hostname                       = string
    enabled                        = optional(bool, true)
    cdn_frontdoor_origin_group_key = string # key from var.origin_group
    certificate_name_check_enabled = bool   # must be true for Private Link
    origin_host_header             = optional(string)
    priority                       = optional(number, 1)   # 1–5
    weight                         = optional(number, 500) # 1–1000
    http_port                      = optional(number, 80)  # 1–65535
    https_port                     = optional(number, 443) # 1–65535

    private_link = optional(object({
      request_message        = optional(string, "Access request for CDN FrontDoor Private Link Origin")
      target_type            = optional(string) # blob, blob_secondary, sites, web, etc.
      location               = string
      private_link_target_id = string
    }))
  }))
}

variable "origin_group" {
  description = "Map of Front Door Origin Group configurations"
  type = map(object({
    session_affinity_enabled                                  = optional(bool, true)
    restore_traffic_time_to_healed_or_new_endpoint_in_minutes = optional(number)

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
  }))
}

variable "resource_group_name" {
  type = string
}

variable "route" {
  description = "Map of Front Door route configurations"
  type = map(object({
    cdn_frontdoor_endpoint_key       = string
    cdn_frontdoor_origin_group_key   = string
    cdn_frontdoor_origin_keys        = list(string)
    cdn_frontdoor_origin_path        = optional(string, null)
    cdn_frontdoor_rule_set_keys      = optional(list(string),[])
    cdn_frontdoor_custom_domain_keys = optional(list(string),[])

    enabled                = optional(bool, true)
    forwarding_protocol    = optional(string, "MatchRequest") # "HttpOnly" | "HttpsOnly" | "MatchRequest"
    https_redirect_enabled = optional(bool, true)
    patterns_to_match      = optional(list(string), ["/*"])
    supported_protocols    = optional(list(string), ["Https"])

    link_to_default_domain = optional(bool, true)

    cache = optional(object({
      query_string_caching_behavior = optional(string, "IgnoreQueryString") # "IgnoreQueryString" etc.
      query_strings                 = optional(list(string))
      compression_enabled           = optional(bool, false)
      content_types_to_compress     = optional(list(string))
    }))
  }))
}

variable "tags" {
  type        = map(string)
  description = "Resource tags to be applied throughout the deployment."
  default     = {}
}

