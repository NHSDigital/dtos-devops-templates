output "topic_endpoint" {
  description = "The event grid topic URL."
  value       = azurerm_eventgrid_topic.azurerm_eventgrid.endpoint
}

output "id" {
  description = "The event grid topic id."
  value       = azurerm_eventgrid_topic.azurerm_eventgrid.id
}
