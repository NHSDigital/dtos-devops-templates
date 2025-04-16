output "app_service_plan_name" {
  value = azurerm_service_plan.appserviceplan.name
}

output "app_service_plan_id" {
  value = azurerm_service_plan.appserviceplan.id
}

output "wildcard_ssl_cert_id" {
  value = length(var.wildcard_ssl_cert_key_vault_secret_id) > 0 ? azurerm_app_service_certificate.wildcard[0].id : null
}
