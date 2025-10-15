output "id" {
  value       = var.use_standard ? azurerm_application_insights_standard_web_test.standard[0].id : azurerm_application_insights_web_test.classic[0].id
  description = "Resource id of the created web test"
}

output "name" {
  value = var.name
}
