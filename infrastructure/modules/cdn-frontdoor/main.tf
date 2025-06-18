resource "azurerm_cdn_frontdoor_endpoint" "this" {
  for_each = var.endpoint

  name                     = each.key
  cdn_frontdoor_profile_id = var.cdn_frontdoor_profile_id
  enabled                  = each.value.enabled

  tags = var.tags
}

resource "azurerm_cdn_frontdoor_origin_group" "this" {
  for_each = var.origin_group

  name                     = each.key
  cdn_frontdoor_profile_id = var.cdn_frontdoor_profile_id
  session_affinity_enabled = each.value.session_affinity_enabled

  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = each.value.restore_traffic_time_to_healed_or_new_endpoint_in_minutes

  dynamic "health_probe" {
    for_each = each.value.health_probe != null ? [1] : []

    content {
      interval_in_seconds = each.value.health_probe.interval_in_seconds
      path                = each.value.health_probe.path
      protocol            = each.value.health_probe.protocol
      request_type        = each.value.health_probe.request_type
    }
  }

  load_balancing {
    additional_latency_in_milliseconds = each.value.load_balancing.additional_latency_in_milliseconds
    sample_size                        = each.value.load_balancing.sample_size
    successful_samples_required        = each.value.load_balancing.successful_samples_required
  }
}

resource "azurerm_cdn_frontdoor_origin" "this" {
  for_each = var.origin

  name                          = each.key
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.this[each.value.cdn_frontdoor_origin_group_key].id
  enabled                       = each.value.enabled

  certificate_name_check_enabled = each.value.certificate_name_check_enabled
  host_name                      = each.value.hostname
  origin_host_header             = each.value.origin_host_header
  priority                       = each.value.priority
  weight                         = each.value.weight

  dynamic "private_link" {
    for_each = each.value.private_link != null ? [1] : []

    content {
      request_message        = each.value.private_link.request_message
      target_type            = each.value.private_link.target_type
      location               = each.value.private_link.location
      private_link_target_id = each.value.private_link.private_link_target_id
    }
  }
}

# resource "azurerm_cdn_frontdoor_custom_domain" "this" {
#   for_each = toset(var.custom_domains)

#   name                     = each.key
#   cdn_frontdoor_profile_id = var.cdn_frontdoor_profile_id
#   dns_zone_id              = azurerm_dns_zone.example.id
#   host_name                = join(".", ["fabrikam", azurerm_dns_zone.example.name])

#   tls {
#     certificate_type    = "ManagedCertificate"
#     minimum_tls_version = "TLS12"
#   }
# }

resource "azurerm_cdn_frontdoor_route" "this" {
  for_each = var.route

  name                          = each.key
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.this[each.value.cdn_frontdoor_endpoint_key].id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin.this[each.value.cdn_frontdoor_origin_group_key].id
  cdn_frontdoor_origin_ids      = [for k in each.value.cdn_frontdoor_origin_keys : azurerm_cdn_frontdoor_origin.this[k].id]
  cdn_frontdoor_origin_path     = each.value.cdn_frontdoor_origin_path
  cdn_frontdoor_rule_set_ids    = can(azurerm_cdn_frontdoor_rule_set.this) ? [for k in each.value.cdn_frontdoor_rule_set_keys : azurerm_cdn_frontdoor_rule_set.this[k].id] : null
  enabled                       = each.value.enabled

  forwarding_protocol    = each.value.forwarding_protocol
  https_redirect_enabled = each.value.https_redirect_enabled
  patterns_to_match      = each.value.patterns_to_match
  supported_protocols    = each.value.supported_protocols

  cdn_frontdoor_custom_domain_ids = can(azurerm_cdn_frontdoor_custom_domain.this) ? [for k in each.value.cdn_frontdoor_custom_domain_keys : azurerm_cdn_frontdoor_custom_domain.this[k].id] : null

  link_to_default_domain          = each.value.link_to_default_domain

  dynamic "cache" {
    for_each = each.value.cache != null ? [1] : []

    content {
      query_string_caching_behavior = each.value.cache.query_string_caching_behavior
      query_strings                 = each.value.cache.query_strings
      compression_enabled           = each.value.cache.compression_enabled
      content_types_to_compress     = each.value.cache.content_types_to_compress
    }
  }
}
