resource "azurerm_container_app_environment" "main" {
  name                           = var.name
  location                       = data.azurerm_resource_group.main.location
  resource_group_name            = var.resource_group_name
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  infrastructure_subnet_id       = var.vnet_integration_subnet_id
  internal_load_balancer_enabled = true
  zone_redundancy_enabled        = var.zone_redundancy_enabled
}

module "apex-record" {
  source = "../private-dns-a-record"
  providers = {
    azurerm = azurerm.dns
  }

  name                = local.dns_record
  resource_group_name = var.private_dns_zone_rg_name
  zone_name           = "azurecontainerapps.io"
  ttl                 = 60
  records             = [azurerm_container_app_environment.main.static_ip_address]
}

module "wildcard-record" {
  source = "../private-dns-a-record"
  providers = {
    azurerm = azurerm.dns
  }

  name                = "*.${local.dns_record}"
  resource_group_name = var.private_dns_zone_rg_name
  zone_name           = "azurecontainerapps.io"
  ttl                 = 60
  records             = [azurerm_container_app_environment.main.static_ip_address]
}
