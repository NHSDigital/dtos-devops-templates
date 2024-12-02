output "name" {
  value = azurerm_eventhub_namespace.eventhub_ns.name
}

output "id" {
  value = azurerm_eventhub_namespace.eventhub_ns.id
}

output "eventhubs" {
  value = azurerm_eventhub.eventhub
}
