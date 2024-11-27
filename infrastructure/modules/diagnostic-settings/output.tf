output "diagnostic_categories_metrics" {
  value = data.azurerm_monitor_diagnostic_categories.this.metrics
}
