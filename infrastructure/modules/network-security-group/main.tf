resource "azurerm_network_security_group" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  # Dynamically create security rules from the variable
  dynamic "security_rule" {
    for_each = var.nsg_rules
    content {
      name                         = security_rule.value.name
      priority                     = security_rule.value.priority
      direction                    = security_rule.value.direction
      access                       = security_rule.value.access
      protocol                     = security_rule.value.protocol
      source_port_range            = security_rule.value.source_port_range == null ? null : security_rule.value.source_port_range
      source_port_ranges           = security_rule.value.source_port_ranges == null ? [] : security_rule.value.source_port_ranges
      destination_port_range       = security_rule.value.destination_port_range == null ? null : security_rule.value.destination_port_range
      destination_port_ranges      = security_rule.value.destination_port_ranges == null ? [] : security_rule.value.destination_port_ranges
      source_address_prefix        = security_rule.value.source_address_prefix == null ? null : security_rule.value.source_address_prefix
      source_address_prefixes      = security_rule.value.source_address_prefixes == null ? [] : security_rule.value.source_address_prefixes
      destination_address_prefix   = security_rule.value.destination_address_prefix == null ? null : security_rule.value.destination_address_prefix
      destination_address_prefixes = security_rule.value.destination_address_prefixes == null ? [] : security_rule.value.destination_address_prefixes
    }
  }

  tags = var.tags
}


/* --------------------------------------------------------------------------------------------------
  Diagnostic Settings
-------------------------------------------------------------------------------------------------- */

module "diagnostic-settings" {
  source = "../diagnostic-settings"

  name                       = "${var.name}-diagnostic-setting"
  target_resource_id         = azurerm_network_security_group.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  enabled_log                = var.monitor_diagnostic_setting_network_security_group_enabled_logs
  metric                     = var.monitor_diagnostic_setting_network_security_group_metrics

}
