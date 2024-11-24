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
    min_protocol_version = var.min_tls_ver
  }

  dynamic "frontend_port" {
    for_each = var.frontend_port

    content = {
      name = var.names.frontend_port_name[frontend_port.key]
      port = frontend_port.value.port
    }
  }

  dynamic "frontend_ip_configuration" {
    for_each = var.frontend_ip_configuration

    content = {
      name                          = var.names.frontend_ip_configuration_name[frontend_ip_configuration.key]
      subnet_id                     = frontend_ip_configuration.value.subnet_id
      public_ip_address_id          = frontend_ip_configuration.value.public_ip_address_id
      private_ip_address            = frontend_ip_configuration.value.private_ip_address
      private_ip_address_allocation = frontend_ip_configuration.value.private_ip_address_allocation
    }
  }

  dynamic "backend_address_pool" {
    for_each = var.backend_address_pool

    content = {
      name         = var.names.backend_address_pool_name[backend_address_pool.key]
      fqdns        = backend_address_pool.value.fqdns
      ip_addresses = backend_address_pool.value.ip_addresses
    }
  }

  dynamic "probe" {
    for_each = var.probe

    content = {
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
        for_each = probe.value.match

        content = {
          status_code = match.value.status_code
          body        = match.value.body
        }
      }
    }
  }

  dynamic "ssl_certificate" {
    for_each = var.ssl_certificate

    content = {
      data                = ssl_certificate.value.data
      key_vault_secret_id = ssl_certificate.value.key_vault_secret_id
      name                = var.names.ssl_certificate[ssl_certificate.key]
      password            = ssl_certificate.value.password
    }
  }

  dynamic "backend_http_settings" {
    for_each = var.backend_http_settings

    content = {
      affinity_cookie_name                = backend_http_settings.value.affinity_cookie_name
      cookie_based_affinity               = backend_http_settings.value.cookie_based_affinity
      host_name                           = backend_http_settings.value.host_name
      name                                = var.names.backend_http_settings_name[backend_http_settings.key]
      path                                = backend_http_settings.value.path
      pick_host_name_from_backend_address = backend_http_settings.value.pick_host_name_from_backend_address
      probe_name                          = var.names.probe[backend_http_settings.value.probe_key]
      port                                = backend_http_settings.value.port
      protocol                            = backend_http_settings.value.protocol
      request_timeout                     = backend_http_settings.value.request_timeout
      trusted_root_certificate_names      = backend_http_settings.value.trusted_root_certificate_names

      dynamic "connection_draining" {
        for_each = backend_http_settings.value.connection_draining

        content = {
          enabled           = connection_draining.value.enabled
          drain_timeout_sec = connection_draining.value.drain_timeout_sec
        }
      }
    }
  }







  http_listener {
    host_name                      = "localhost"
    name                           = var.names.unused.http_listener_name
    frontend_ip_configuration_name = var.names.common_public.frontend_ip_configuration_name
    frontend_port_name             = var.names.unused.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = var.names.unused.rule_name
    rule_type                  = "Basic"
    http_listener_name         = var.names.unused.http_listener_name
    backend_address_pool_name  = var.names.unused.backend_address_pool_name
    backend_http_settings_name = var.names.unused.backend_http_settings_name
    priority                   = 20000
  }

  depends_on = [
    module.key_vault_rbac_assignments
  ]

  tags = var.tags
}

resource "azurerm_user_assigned_identity" "appgw" {
  name                = var.names.managed_identity_name
  resource_group_name = var.resource_group_name
  location            = var.location
}
