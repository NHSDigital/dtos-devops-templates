resource "azurerm_cdn_frontdoor_rule_set" "this" {
  name                     = var.name
  cdn_frontdoor_profile_id = var.cdn_frontdoor_profile_id
}

# Written by AI since it was so onerous to replicate all this. It is untested since it was not immediately required. YMMV.
resource "azurerm_cdn_frontdoor_rule" "this" {
  for_each = var.rule

  name                      = each.value.name
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.this.id
  order                     = each.value.order
  behavior_on_match         = try(each.value.behavior_on_match, null)

  dynamic "actions" {
    for_each = try(each.value.actions, [])
    content {
      dynamic "url_rewrite_action" {
        for_each = try(actions.value.url_rewrite_action, [])
        content {
          source_pattern          = url_rewrite_action.value.source_pattern
          destination             = url_rewrite_action.value.destination
          preserve_unmatched_path = try(url_rewrite_action.value.preserve_unmatched_path, null)
        }
      }

      dynamic "url_redirect_action" {
        for_each = try(actions.value.url_redirect_action, [])
        content {
          redirect_type        = url_redirect_action.value.redirect_type
          destination_hostname = url_redirect_action.value.destination_hostname
          redirect_protocol    = try(url_redirect_action.value.redirect_protocol, null)
          destination_path     = try(url_redirect_action.value.destination_path, null)
          query_string         = try(url_redirect_action.value.query_string, null)
          destination_fragment = try(url_redirect_action.value.destination_fragment, null)
        }
      }

      dynamic "route_configuration_override_action" {
        for_each = try(actions.value.route_configuration_override_action, [])
        content {
          cache_duration                = try(route_configuration_override_action.value.cache_duration, null)
          cdn_frontdoor_origin_group_id = try(route_configuration_override_action.value.cdn_frontdoor_origin_group_id, null)
          forwarding_protocol           = try(route_configuration_override_action.value.forwarding_protocol, null)
          query_string_caching_behavior = try(route_configuration_override_action.value.query_string_caching_behavior, null)
          query_string_parameters       = try(route_configuration_override_action.value.query_string_parameters, null)
          compression_enabled           = try(route_configuration_override_action.value.compression_enabled, null)
          cache_behavior                = try(route_configuration_override_action.value.cache_behavior, null)
        }
      }

      dynamic "request_header_action" {
        for_each = try(actions.value.request_header_action, [])
        content {
          header_action = request_header_action.value.header_action
          header_name   = request_header_action.value.header_name
          value         = try(request_header_action.value.value, null)
        }
      }

      dynamic "response_header_action" {
        for_each = try(actions.value.response_header_action, [])
        content {
          header_action = response_header_action.value.header_action
          header_name   = response_header_action.value.header_name
          value         = try(response_header_action.value.value, null)
        }
      }
    }
  }

  dynamic "conditions" {
    for_each = try(each.value.conditions, [])
    content {
      dynamic "request_method_condition" {
        for_each = try(conditions.value.request_method_condition, [])
        content {
          match_values     = request_method_condition.value.match_values
          operator         = try(request_method_condition.value.operator, null)
          negate_condition = try(request_method_condition.value.negate_condition, null)
        }
      }

      dynamic "remote_address_condition" {
        for_each = try(conditions.value.remote_address_condition, [])
        content {
          operator         = try(remote_address_condition.value.operator, null)
          negate_condition = try(remote_address_condition.value.negate_condition, null)
          match_values     = try(remote_address_condition.value.match_values, null)
        }
      }

      dynamic "request_uri_condition" {
        for_each = try(conditions.value.request_uri_condition, [])
        content {
          operator         = request_uri_condition.value.operator
          negate_condition = try(request_uri_condition.value.negate_condition, null)
          match_values     = try(request_uri_condition.value.match_values, null)
          transforms       = try(request_uri_condition.value.transforms, null)
        }
      }

      dynamic "request_header_condition" {
        for_each = try(conditions.value.request_header_condition, [])
        content {
          header_name      = request_header_condition.value.header_name
          operator         = request_header_condition.value.operator
          negate_condition = try(request_header_condition.value.negate_condition, null)
          match_values     = try(request_header_condition.value.match_values, null)
          transforms       = try(request_header_condition.value.transforms, null)
        }
      }

      dynamic "url_path_condition" {
        for_each = try(conditions.value.url_path_condition, [])
        content {
          operator         = url_path_condition.value.operator
          negate_condition = try(url_path_condition.value.negate_condition, null)
          match_values     = try(url_path_condition.value.match_values, null)
          transforms       = try(url_path_condition.value.transforms, null)
        }
      }

      dynamic "query_string_condition" {
        for_each = try(conditions.value.query_string_condition, [])
        content {
          operator         = query_string_condition.value.operator
          negate_condition = try(query_string_condition.value.negate_condition, null)
          match_values     = try(query_string_condition.value.match_values, null)
          transforms       = try(query_string_condition.value.transforms, null)
        }
      }

      dynamic "post_args_condition" {
        for_each = try(conditions.value.post_args_condition, [])
        content {
          post_args_name   = post_args_condition.value.post_args_name
          operator         = post_args_condition.value.operator
          negate_condition = try(post_args_condition.value.negate_condition, null)
          match_values     = try(post_args_condition.value.match_values, null)
          transforms       = try(post_args_condition.value.transforms, null)
        }
      }

      dynamic "request_scheme_condition" {
        for_each = try(conditions.value.request_scheme_condition, [])
        content {
          operator         = try(request_scheme_condition.value.operator, null)
          negate_condition = try(request_scheme_condition.value.negate_condition, null)
          match_values     = try(request_scheme_condition.value.match_values, null)
        }
      }

      dynamic "socket_address_condition" {
        for_each = try(conditions.value.socket_address_condition, [])
        content {
          operator         = try(socket_address_condition.value.operator, null)
          negate_condition = try(socket_address_condition.value.negate_condition, null)
          match_values     = try(socket_address_condition.value.match_values, null)
        }
      }

      dynamic "client_port_condition" {
        for_each = try(conditions.value.client_port_condition, [])
        content {
          operator         = client_port_condition.value.operator
          negate_condition = try(client_port_condition.value.negate_condition, null)
          match_values     = try(client_port_condition.value.match_values, null)
        }
      }

      dynamic "server_port_condition" {
        for_each = try(conditions.value.server_port_condition, [])
        content {
          operator         = server_port_condition.value.operator
          negate_condition = try(server_port_condition.value.negate_condition, null)
          match_values     = try(server_port_condition.value.match_values, null)
        }
      }

      dynamic "host_name_condition" {
        for_each = try(conditions.value.host_name_condition, [])
        content {
          operator         = host_name_condition.value.operator
          match_values     = try(host_name_condition.value.match_values, null)
          transforms       = try(host_name_condition.value.transforms, null)
          negate_condition = try(host_name_condition.value.negate_condition, null)
        }
      }

      dynamic "ssl_protocol_condition" {
        for_each = try(conditions.value.ssl_protocol_condition, [])
        content {
          match_values     = ssl_protocol_condition.value.match_values
          operator         = try(ssl_protocol_condition.value.operator, null)
          negate_condition = try(ssl_protocol_condition.value.negate_condition, null)
        }
      }

      dynamic "cookies_condition" {
        for_each = try(conditions.value.cookies_condition, [])
        content {
          cookie_name      = cookies_condition.value.cookie_name
          operator         = cookies_condition.value.operator
          match_values     = try(cookies_condition.value.match_values, null)
          transforms       = try(cookies_condition.value.transforms, null)
          negate_condition = try(cookies_condition.value.negate_condition, null)
        }
      }

      dynamic "request_body_condition" {
        for_each = try(conditions.value.request_body_condition, [])
        content {
          operator         = request_body_condition.value.operator
          match_values     = request_body_condition.value.match_values
          negate_condition = try(request_body_condition.value.negate_condition, null)
          transforms       = try(request_body_condition.value.transforms, null)
        }
      }

      dynamic "url_file_extension_condition" {
        for_each = try(conditions.value.url_file_extension_condition, [])
        content {
          operator         = url_file_extension_condition.value.operator
          match_values     = url_file_extension_condition.value.match_values
          negate_condition = try(url_file_extension_condition.value.negate_condition, null)
          transforms       = try(url_file_extension_condition.value.transforms, null)
        }
      }

      dynamic "url_filename_condition" {
        for_each = try(conditions.value.url_filename_condition, [])
        content {
          operator         = url_filename_condition.value.operator
          match_values     = try(url_filename_condition.value.match_values, null)
          negate_condition = try(url_filename_condition.value.negate_condition, null)
          transforms       = try(url_filename_condition.value.transforms, null)
        }
      }

      dynamic "http_version_condition" {
        for_each = try(conditions.value.http_version_condition, [])
        content {
          match_values     = http_version_condition.value.match_values
          operator         = try(http_version_condition.value.operator, null)
          negate_condition = try(http_version_condition.value.negate_condition, null)
        }
      }

      dynamic "is_device_condition" {
        for_each = try(conditions.value.is_device_condition, [])
        content {
          match_values     = try(is_device_condition.value.match_values, null)
          operator         = try(is_device_condition.value.operator, null)
          negate_condition = try(is_device_condition.value.negate_condition, null)
        }
      }
    }
  }

  depends_on = [
    azurerm_cdn_frontdoor_origin_group.this,
    azurerm_cdn_frontdoor_origin.this
  ]
}
