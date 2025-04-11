resource "azurerm_app_service_certificate" "wildcard" {
  count = var.wildcard_ssl_cert_key_vault_secret_id != null ? 1 : 0

  name                = var.wildcard_ssl_cert_name
  resource_group_name = var.resource_group_name
  location            = var.location

  app_service_plan_id = azurerm_service_plan.appserviceplan.id
  key_vault_secret_id = var.wildcard_ssl_cert_key_vault_secret_id
  key_vault_id        = var.wildcard_ssl_cert_key_vault_id
}
