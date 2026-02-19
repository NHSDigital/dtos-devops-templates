resource "azurerm_cdn_frontdoor_endpoint" "this" {
  name                     = var.name
  cdn_frontdoor_profile_id = var.cdn_frontdoor_profile_id
  enabled                  = true

  tags = var.tags
}

resource "azurerm_cdn_frontdoor_origin_group" "this" {
  name                     = "${var.name}-origins"
  cdn_frontdoor_profile_id = var.cdn_frontdoor_profile_id
  session_affinity_enabled = var.origin_group.session_affinity_enabled

  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = var.origin_group.restore_traffic_time_to_healed_or_new_endpoint_in_minutes

  dynamic "health_probe" {
    for_each = var.origin_group.health_probe != null ? [1] : []

    content {
      interval_in_seconds = var.origin_group.health_probe.interval_in_seconds
      path                = var.origin_group.health_probe.path
      protocol            = var.origin_group.health_probe.protocol
      request_type        = var.origin_group.health_probe.request_type
    }
  }

  load_balancing {
    additional_latency_in_milliseconds = var.origin_group.load_balancing.additional_latency_in_milliseconds
    sample_size                        = var.origin_group.load_balancing.sample_size
    successful_samples_required        = var.origin_group.load_balancing.successful_samples_required
  }
}

resource "azurerm_cdn_frontdoor_origin" "this" {
  for_each = var.origins

  name                          = each.key
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.this.id
  enabled                       = each.value.enabled

  certificate_name_check_enabled = true
  host_name                      = each.value.hostname
  origin_host_header             = each.value.origin_host_header
  priority                       = each.value.priority
  weight                         = each.value.weight

  dynamic "private_link" {
    for_each = each.value.private_link != null ? [1] : []

    content {
      request_message        = substr("CDN Front Door connection from origin ${each.key} in ${azurerm_cdn_frontdoor_origin_group.this.name} in profile ${reverse(split("/", var.cdn_frontdoor_profile_id))[0]}", 0, 140)
      target_type            = each.value.private_link.target_type
      location               = each.value.private_link.location
      private_link_target_id = each.value.private_link.private_link_target_id
    }
  }
}

resource "azurerm_cdn_frontdoor_custom_domain" "this" {
  for_each = var.custom_domains

  name                     = each.key
  cdn_frontdoor_profile_id = var.cdn_frontdoor_profile_id
  dns_zone_id              = data.azurerm_dns_zone.custom[each.key].id
  host_name                = each.value.host_name

  tls {
    certificate_type        = each.value.tls.certificate_type
    cdn_frontdoor_secret_id = each.value.tls.cdn_frontdoor_secret_id
  }

  depends_on = [
    azurerm_dns_a_record.root_alias,
    azurerm_dns_cname_record.custom
  ]
}

resource "azurerm_cdn_frontdoor_route" "this" {
  name                          = "${var.name}-route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.this.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.this.id
  cdn_frontdoor_origin_ids      = [for k in keys(var.origins) : azurerm_cdn_frontdoor_origin.this[k].id]
  cdn_frontdoor_origin_path     = var.route.cdn_frontdoor_origin_path
  cdn_frontdoor_rule_set_ids    = var.route.cdn_frontdoor_rule_set_ids
  enabled                       = var.route.enabled

  forwarding_protocol    = var.route.forwarding_protocol
  https_redirect_enabled = var.route.https_redirect_enabled
  patterns_to_match      = var.route.patterns_to_match
  supported_protocols    = var.route.supported_protocols

  cdn_frontdoor_custom_domain_ids = [for k in keys(var.custom_domains) : azurerm_cdn_frontdoor_custom_domain.this[k].id]
  link_to_default_domain          = var.custom_domains == {} && var.route.link_to_default_domain == false ? true : var.route.link_to_default_domain

  dynamic "cache" {
    for_each = var.route.cache != null ? [1] : []

    content {
      query_string_caching_behavior = var.route.cache.query_string_caching_behavior
      query_strings                 = var.route.cache.query_strings
      compression_enabled           = var.route.cache.compression_enabled
      content_types_to_compress     = var.route.cache.content_types_to_compress
    }
  }
}

resource "azurerm_cdn_frontdoor_security_policy" "this" {
  for_each = var.security_policies

  name                     = "${var.name}-${each.key}"
  cdn_frontdoor_profile_id = var.cdn_frontdoor_profile_id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = each.value.cdn_frontdoor_firewall_policy_id != null ? each.value.cdn_frontdoor_firewall_policy_id : data.azurerm_cdn_frontdoor_firewall_policy.waf[each.key].id

      association {
        patterns_to_match = ["/*"]

        dynamic "domain" {
          for_each = toset(each.value.associated_domain_keys)

          content {
            cdn_frontdoor_domain_id = lower(domain.key) == "endpoint" ? azurerm_cdn_frontdoor_endpoint.this.id : azurerm_cdn_frontdoor_custom_domain.this[domain.key].id
          }
        }
      }
    }
  }
}
