# 4xx Error Alert for Azure Function App - these are client errors, usually invalid requests (400) or authentication issues (401, 403)
resource "azurerm_monitor_metric_alert" "function_4xx" {
  count = var.enable_alerting == true ? 1 : 0

  name                = "${azurerm_linux_function_app.function_app.name}-4xx-errors"
  resource_group_name = var.resource_group_name_monitoring != null ? var.resource_group_name_monitoring : var.resource_group_name
  scopes              = [azurerm_linux_function_app.function_app.id] # Point to your function app
  description         = "Action will be triggered when 4xx errors exceed ${var.alert_4xx_threshold}"
  window_size         = var.alert_window_size
  frequency           = local.alert_frequency
  severity            = 2 # Warning

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http4xx"
    aggregation      = "Total" # Count total 4xx errors
    operator         = "GreaterThan"
    threshold        = var.alert_4xx_threshold
  }

  action {
    action_group_id = var.action_group_id
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

# 5xx error alert - these are server errors and more serious than 4xx errors
resource "azurerm_monitor_metric_alert" "function_5xx" {
  count = var.enable_alerting == true ? 1 : 0

  name                = "${azurerm_linux_function_app.function_app.name}-5xx-errors"
  resource_group_name = var.resource_group_name_monitoring != null ? var.resource_group_name_monitoring : var.resource_group_name
  scopes              = [azurerm_linux_function_app.function_app.id] # Point to your function app
  description         = "Action will be triggered when 5xx errors exceed ${var.alert_5xx_threshold}"
  window_size         = var.alert_window_size
  frequency           = local.alert_frequency
  severity            = 2 # Warning

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http5xx"
    aggregation      = "Total" # Count total 5xx errors
    operator         = "GreaterThan"
    threshold        = var.alert_5xx_threshold
  }

  action {
    action_group_id = var.action_group_id
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
