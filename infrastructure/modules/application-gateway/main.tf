# Many Application Gateway parameters are mandatory for resource creation...
# so create an unused config on port 80, which the Network Security Group rules will block from public access

resource "azurerm_application_gateway" "this" {
  name                = var.common_names.name
  resource_group_name = var.resource_group_name
  location            = var.location
  zones               = var.zones

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
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
    name      = var.common_names.gateway_ip_configuration_name
    subnet_id = var.gateway_subnet.id
  }

  frontend_port {
    name = var.common_names.unused.frontend_port_name
    port = 80
  }

  frontend_port {
    name = var.common_names.common_public.frontend_port_name
    port = 443
  }

  frontend_port {
    name = var.common_names.common_private.frontend_port_name
    port = 440
  }

  frontend_ip_configuration {
    name                 = var.common_names.common_public.frontend_ip_configuration_name
    public_ip_address_id = var.public_ip_address_id
  }

  frontend_ip_configuration {
    name                          = var.common_names.common_private.frontend_ip_configuration_name
    subnet_id                     = var.gateway_subnet.id
    private_ip_address            = cidrhost(var.gateway_subnet.address_prefixes[0], 225)
    private_ip_address_allocation = "Static"
  }

  backend_address_pool {
    name = var.common_names.unused.backend_address_pool_name
  }

  probe {
    host                                      = "unused.nhs.uk"
    interval                                  = 30
    name                                      = var.common_names.unused.probe_name
    path                                      = "/"
    pick_host_name_from_backend_http_settings = false
    protocol                                  = "Http"
    timeout                                   = 10
    unhealthy_threshold                       = 3

    match {
      status_code = ["200"]
    }
  }

  backend_http_settings {
    name                  = var.common_names.unused.backend_http_settings_name
    cookie_based_affinity = "Disabled"
    probe_name            = var.common_names.unused.probe_name
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60

    connection_draining {
      enabled           = true
      drain_timeout_sec = 120
    }
  }

  ssl_policy {
    min_protocol_version = var.min_tls_ver
  }

  http_listener {
    host_name                      = "localhost"
    name                           = var.common_names.unused.http_listener_name
    frontend_ip_configuration_name = var.common_names.common_public.frontend_ip_configuration_name
    frontend_port_name             = var.common_names.unused.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = var.common_names.unused.rule_name
    rule_type                  = "Basic"
    http_listener_name         = var.common_names.unused.http_listener_name
    backend_address_pool_name  = var.common_names.unused.backend_address_pool_name
    backend_http_settings_name = var.common_names.unused.backend_http_settings_name
    priority                   = 20000
  }

  lifecycle {
    ignore_changes = all # application settings will be inserted by each spoke Terraform state, using PowerShell
  }

  tags = var.tags
}
