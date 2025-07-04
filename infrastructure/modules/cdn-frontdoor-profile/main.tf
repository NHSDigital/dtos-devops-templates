resource "azurerm_cdn_frontdoor_profile" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  sku_name            = var.sku_name

  response_timeout_seconds = var.response_timeout_seconds

  dynamic "identity" {
    for_each = var.identity != null ? [1] : []

    content {
      type         = var.identity.type
      identity_ids = strcontains(var.identity.type, "UserAssigned") ? var.identity.identity_ids : null
    }
  }

  tags = var.tags
}

resource "azurerm_cdn_frontdoor_secret" "this" {
  for_each = var.certificate_secrets

  name                     = each.key
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id

  secret {
    customer_certificate {
      key_vault_certificate_id = each.value
    }
  }
}

module "diagnostic-settings" {
  source = "../diagnostic-settings"

  count = var.log_analytics_workspace_id != null ? 1 : 0

  name                       = "${var.name}-diagnostic-setting"
  target_resource_id         = azurerm_cdn_frontdoor_profile.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  enabled_log                = var.monitor_diagnostic_setting_frontdoor_enabled_logs
  metric                     = var.monitor_diagnostic_setting_frontdoor_metrics
  metric_enabled             = var.metric_enabled
}
