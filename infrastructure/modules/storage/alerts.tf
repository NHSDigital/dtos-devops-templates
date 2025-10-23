resource "azurerm_monitor_metric_alert" "storage_queue_transactions_high" {
  for_each = var.enable_alerting ? toset(var.queues) : toset([])

  name                = "${each.key}-transactions-backlog"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_storage_account.storage_account.id]
  description         = "Storage queue transactions exceed ${var.queue_transactions_high_threshold} messages within ${var.alert_window_size}."
  severity            = 2
  frequency           = local.alert_frequency
  window_size         = var.alert_window_size

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "Transactions"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.queue_transactions_high_threshold
  }

  action {
    action_group_id = var.action_group_id
  }
}

resource "azurerm_monitor_metric_alert" "availability_low" {
  for_each = var.enable_alerting ? toset(var.queues) : toset([])

  name                = "${each.key}-availability-low"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_storage_account.storage_account.id]
  description         = "Storage account availability is below the threshold of ${var.availability_low_threshold}%."
  severity            = 2
  frequency           = local.alert_frequency
  window_size         = var.alert_window_size

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "Availability"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = var.availability_low_threshold
  }

  action {
    action_group_id = var.action_group_id
  }
}

resource "azurerm_monitor_metric_alert" "success_E2E_latency" {
  for_each = var.enable_alerting ? toset(var.queues) : toset([])

  name                = "${each.key}-latency"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_storage_account.storage_account.id]
  description         = "End-to-end success latency exceeds ${var.success_e2e_latency_threshold} ms."
  severity            = 2
  frequency           = local.alert_frequency
  window_size         = var.alert_window_size

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "SuccessE2ELatency"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.success_e2e_latency_threshold
  }

  action {
    action_group_id = var.action_group_id
  }
}

# resource "azurerm_monitor_metric_alert" "queue_length_exceeded" {
#   for_each = var.enable_alerting ? toset(var.queues) : toset([])

#   name                = "${each.key}-queue-length"
#   resource_group_name = var.resource_group_name
#   scopes              = [azurerm_storage_account.storage_account.id]
#   description         = "Number of messages in the queue above threshold (${var.queue_length_threshold})."
#   severity            = 2
#   frequency           = local.alert_frequency
#   window_size         = var.alert_window_size

#   criteria {
#     metric_namespace = "Microsoft.Storage/storageAccounts"
#     metric_name      = "QueueMessageCount"
#     aggregation      = "Average"
#     operator         = "GreaterThan"
#     threshold        = var.queue_length_threshold

#     dimension {
#       name     = "QueueName"
#       operator = "Include"
#       values   = [each.key]
#     }
#   }

#   action {
#     action_group_id = var.action_group_id
#   }
# }
