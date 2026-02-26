module "pip" {
  source = "../public-ip"

  name                = var.public_ip_name
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.zones

  tags = var.tags
}

resource "azurerm_bastion_host" "bastion" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku

  copy_paste_enabled     = var.copy_paste_enabled
  file_copy_enabled      = var.file_copy_enabled
  ip_connect_enabled     = var.ip_connect_enabled
  tunneling_enabled      = var.tunneling_enabled
  shareable_link_enabled = var.shareable_link_enabled
  scale_units            = var.scale_units

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.subnet_id
    public_ip_address_id = module.pip.id
  }

  tags = var.tags
}

module "diagnostic_settings" {
  source = "../diagnostic-settings"

  name                       = "${var.name}-diagnostic-setting"
  target_resource_id         = azurerm_bastion_host.bastion.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  enabled_log                = var.monitor_diagnostic_setting_bastion_enabled_logs
  enabled_metric             = var.monitor_diagnostic_setting_bastion_metrics
}
