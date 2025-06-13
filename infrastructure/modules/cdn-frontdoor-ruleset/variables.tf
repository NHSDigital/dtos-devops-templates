variable "cdn_frontdoor_profile_id" {
  description = "ID of the Front Door profile to associate the Ruleset with"
  type        = string
}

variable "name" {
  description = "Name of the Azure CDN Front Door Ruleset"
  type        = string
}

variable "rules" {
  description = "Map of Front Door Rule configurations"
  type = map(object({
    name                      = string
    cdn_frontdoor_rule_set_id = string
    order                     = number
    behavior_on_match         = optional(string) # Continue or Stop

    actions = object({
      url_rewrite_action = optional(object({
        source_pattern          = string
        destination             = string
        preserve_unmatched_path = optional(bool)
      }))
      url_redirect_action = optional(object({
        redirect_type        = string
        destination_hostname = string
        redirect_protocol    = optional(string)
        destination_path     = optional(string)
        query_string         = optional(string)
        destination_fragment = optional(string)
      }))
      route_configuration_override_action = optional(object({
        cache_duration                = optional(string)
        cdn_frontdoor_origin_group_id = optional(string)
        forwarding_protocol           = optional(string)
        query_string_caching_behavior = optional(string)
        query_string_parameters       = optional(list(string))
        compression_enabled           = optional(bool)
        cache_behavior                = optional(string)
      }))
      request_header_action = optional(list(object({
        header_action = string
        header_name   = string
        value         = optional(string)
      })))
      response_header_action = optional(list(object({
        header_action = string
        header_name   = string
        value         = optional(string)
      })))
    })

    conditions = optional(object({
      ssl_protocol_condition = optional(object({
        match_values     = list(string)
        operator         = optional(string)
        negate_condition = optional(bool)
      }))
      host_name_condition = optional(object({
        operator         = string
        match_values     = optional(list(string))
        transforms       = optional(list(string))
        negate_condition = optional(bool)
      }))
      server_port_condition = optional(object({
        operator         = string
        match_values     = list(number)
        negate_condition = optional(bool)
      }))
      client_port_condition = optional(object({
        operator         = string
        match_values     = optional(list(number))
        negate_condition = optional(bool)
      }))
      socket_address_condition = optional(object({
        operator         = optional(string)
        match_values     = optional(list(string))
        negate_condition = optional(bool)
      }))
      remote_address_condition = optional(object({
        operator         = optional(string)
        match_values     = optional(list(string))
        negate_condition = optional(bool)
      }))
      request_method_condition = optional(object({
        match_values     = list(string)
        operator         = optional(string)
        negate_condition = optional(bool)
      }))
      query_string_condition = optional(object({
        operator         = string
        match_values     = optional(list(string))
        transforms       = optional(list(string))
        negate_condition = optional(bool)
      }))
      post_args_condition = optional(object({
        post_args_name   = string
        operator         = string
        match_values     = optional(list(string))
        transforms       = optional(list(string))
        negate_condition = optional(bool)
      }))
      request_uri_condition = optional(object({
        operator         = string
        match_values     = optional(list(string))
        transforms       = optional(list(string))
        negate_condition = optional(bool)
      }))
      request_header_condition = optional(object({
        header_name      = string
        operator         = string
        match_values     = optional(list(string))
        transforms       = optional(list(string))
        negate_condition = optional(bool)
      }))
      request_body_condition = optional(object({
        operator         = string
        match_values     = list(string)
        transforms       = optional(list(string))
        negate_condition = optional(bool)
      }))
      request_scheme_condition = optional(object({
        operator         = optional(string)
        match_values     = optional(list(string))
        negate_condition = optional(bool)
      }))
      url_path_condition = optional(object({
        operator         = string
        match_values     = optional(list(string))
        transforms       = optional(list(string))
        negate_condition = optional(bool)
      }))
      url_file_extension_condition = optional(object({
        operator         = string
        match_values     = list(string)
        transforms       = optional(list(string))
        negate_condition = optional(bool)
      }))
      url_filename_condition = optional(object({
        operator         = string
        match_values     = optional(list(string))
        transforms       = optional(list(string))
        negate_condition = optional(bool)
      }))
      http_version_condition = optional(object({
        match_values     = list(string)
        operator         = optional(string)
        negate_condition = optional(bool)
      }))
      cookies_condition = optional(object({
        cookie_name      = string
        operator         = string
        match_values     = optional(list(string))
        transforms       = optional(list(string))
        negate_condition = optional(bool)
      }))
      is_device_condition = optional(object({
        match_values     = optional(list(string))
        operator         = optional(string)
        negate_condition = optional(bool)
      }))
    }))
  }))
}
