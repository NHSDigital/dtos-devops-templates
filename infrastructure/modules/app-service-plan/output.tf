output "app_service_plan_name" {
  value = azurerm_service_plan.appserviceplan.name
}

output "app_service_plan_id" {
  value = azurerm_service_plan.appserviceplan.id
}

output "wildcard_ssl_cert_id" {
  value = var.wildcard_ssl_cert_pfx_blob_key_vault_secret_name != null ? azurerm_app_service_certificate.wildcard[0].id : null
}
