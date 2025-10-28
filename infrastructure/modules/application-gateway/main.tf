data "azurerm_client_config" "current" {}

resource "azurerm_application_gateway" "this" {
  name                = var.names.name
  resource_group_name = var.resource_group_name
  location            = var.location
  zones               = var.zones

  sku {
    name     = var.sku
    tier     = var.sku
    capacity = var.autoscale_min == null || var.autoscale_max == null ? 1 : null
  }

  dynamic "autoscale_configuration" {
    for_each = var.autoscale_min != null && var.autoscale_max != null ? [1] : []

    content {
      min_capacity = var.autoscale_min
      max_capacity = var.autoscale_max
    }
  }

  gateway_ip_configuration {
    name      = var.names.gateway_ip_configuration_name
    subnet_id = var.gateway_subnet.id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.appgw.id]
  }

  ssl_policy {
    policy_type = "Predefined"
    policy_name = var.ssl_policy_name
  }

  dynamic "frontend_port" {
    for_each = var.frontend_port

    content {
      name = var.names.frontend_port_name[frontend_port.key]
      port = frontend_port.value
    }
  }

  dynamic "frontend_ip_configuration" {
    for_each = var.frontend_ip_configuration

    content {
      name                          = var.names.frontend_ip_configuration_name[frontend_ip_configuration.key]
      subnet_id                     = frontend_ip_configuration.value.subnet_id
      public_ip_address_id          = frontend_ip_configuration.value.public_ip_address_id
      private_ip_address            = frontend_ip_configuration.value.private_ip_address
      private_ip_address_allocation = frontend_ip_configuration.value.private_ip_address_allocation
    }
  }

  dynamic "backend_address_pool" {
    for_each = var.backend_address_pool

    content {
      name         = var.names.backend_address_pool_name[backend_address_pool.key]
      fqdns        = backend_address_pool.value.fqdns
      ip_addresses = backend_address_pool.value.ip_addresses
    }
  }

  dynamic "probe" {
    for_each = var.probe

    content {
      host                                      = probe.value.host
      interval                                  = probe.value.interval
      minimum_servers                           = probe.value.minimum_servers
      name                                      = var.names.probe_name[probe.key]
      path                                      = probe.value.path
      pick_host_name_from_backend_http_settings = probe.value.pick_host_name_from_backend_http_settings
      port                                      = probe.value.port
      protocol                                  = probe.value.protocol
      timeout                                   = probe.value.timeout
      unhealthy_threshold                       = probe.value.unhealthy_threshold

      dynamic "match" {
        for_each = probe.value.match != null ? [1] : []

        content {
          status_code = probe.value.match.status_code
          body        = probe.value.match.body
        }
      }
    }
  }

  dynamic "ssl_certificate" {
    for_each = var.ssl_certificate

    content {
      data                = ssl_certificate.value.data
      key_vault_secret_id = ssl_certificate.value.key_vault_secret_id
      name                = ssl_certificate.key
      password            = ssl_certificate.value.password
    }
  }

  dynamic "backend_http_settings" {
    for_each = var.backend_http_settings

    content {
      affinity_cookie_name                = backend_http_settings.value.affinity_cookie_name
      cookie_based_affinity               = backend_http_settings.value.cookie_based_affinity
      host_name                           = backend_http_settings.value.host_name
      name                                = var.names.backend_http_settings_name[backend_http_settings.key]
      path                                = backend_http_settings.value.path
      pick_host_name_from_backend_address = backend_http_settings.value.pick_host_name_from_backend_address
      probe_name                          = backend_http_settings.value.probe_key != null ? var.names.probe_name[backend_http_settings.value.probe_key] : null
      port                                = backend_http_settings.value.port
      protocol                            = backend_http_settings.value.protocol
      request_timeout                     = backend_http_settings.value.request_timeout
      trusted_root_certificate_names      = backend_http_settings.value.trusted_root_certificate_names

      dynamic "connection_draining" {
        for_each = backend_http_settings.value.connection_draining != null ? [1] : []

        content {
          enabled           = backend_http_settings.value.connection_draining.enabled
          drain_timeout_sec = backend_http_settings.value.connection_draining.drain_timeout_sec
        }
      }
    }
  }

  dynamic "http_listener" {
    for_each = var.http_listener

    content {
      host_name                      = http_listener.value.host_name
      host_names                     = http_listener.value.host_names
      name                           = var.names.http_listener_name[http_listener.key]
      firewall_policy_id             = http_listener.value.firewall_policy_id
      frontend_ip_configuration_name = var.names.frontend_ip_configuration_name[http_listener.value.frontend_ip_configuration_key]
      frontend_port_name             = var.names.frontend_port_name[http_listener.value.frontend_port_key]
      protocol                       = http_listener.value.protocol
      require_sni                    = http_listener.value.require_sni
      ssl_certificate_name           = http_listener.value.ssl_certificate_key
      ssl_profile_name               = http_listener.value.ssl_profile_name
    }
  }

  dynamic "request_routing_rule" {
    for_each = var.request_routing_rule

    content {
      name                       = var.names.rule_name[request_routing_rule.key]
      rule_type                  = request_routing_rule.value.rule_type
      http_listener_name         = var.names.http_listener_name[request_routing_rule.value.http_listener_key]
      backend_address_pool_name  = var.names.backend_address_pool_name[request_routing_rule.value.backend_address_pool_key]
      backend_http_settings_name = var.names.backend_http_settings_name[request_routing_rule.value.backend_http_settings_key]
      priority                   = request_routing_rule.value.priority
      rewrite_rule_set_name      = try(var.names.rewrite_rule_set_name[request_routing_rule.value.rewrite_rule_set_key], null)
    }
  }

  dynamic "rewrite_rule_set" {
    for_each = var.rewrite_rule_set

    content {
      name = var.names.rewrite_rule_set_name[rewrite_rule_set.key]

      dynamic "rewrite_rule" {
        for_each = rewrite_rule_set.value.rewrite_rule

        content {
          name          = rewrite_rule.key
          rule_sequence = rewrite_rule.value.rule_sequence

          dynamic "condition" {
            for_each = coalesce(rewrite_rule.value.condition, {})

            content {
              variable    = condition.value.variable
              pattern     = condition.value.pattern
              ignore_case = condition.value.ignore_case
              negate      = condition.value.negate
            }
          }

          dynamic "response_header_configuration" {
            for_each = coalesce(rewrite_rule.value.response_header_configuration, {})

            content {
              header_name  = response_header_configuration.key
              header_value = response_header_configuration.value
            }
          }

          dynamic "request_header_configuration" {
            for_each = coalesce(rewrite_rule.value.request_header_configuration, {})

            content {
              header_name  = request_header_configuration.key
              header_value = request_header_configuration.value
            }
          }

          dynamic "url" {
            for_each = rewrite_rule.value.url != null ? [1] : []

            content {
              path         = rewrite_rule.value.url.path
              query_string = rewrite_rule.value.url.query_string
              components   = rewrite_rule.value.url.components
              reroute      = rewrite_rule.value.url.reroute
            }
          }
        }
      }
    }
  }

  depends_on = [
    azurerm_key_vault_access_policy.appgw
  ]

  tags = var.tags
}

resource "azurerm_user_assigned_identity" "appgw" {
  name                = var.names.managed_identity_name
  resource_group_name = var.resource_group_name
  location            = var.location
}

# Application Gateway cannot use RBAC auth for Key Vault, unless by PowerShell. An Azure Policy exemption will be needed when this is forbidden by NHS
# https://learn.microsoft.com/azure/application-gateway/key-vault-certs?WT.mc_id=Portal-Microsoft_Azure_HybridNetworking#key-vault-azure-role-based-access-control-permission-model
resource "azurerm_key_vault_access_policy" "appgw" {
  key_vault_id = var.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.appgw.principal_id

  secret_permissions = [
    "Get",
    "List",
  ]

  certificate_permissions = [
    "Get",
    "List",
  ]
}
