resource "azurerm_linux_function_app" "function_app" {

  name                = var.function_app_name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = var.asp_id

  app_settings = var.app_settings

  https_only = var.https_only

  # Commented out as does not seem compatible with the current version of the azurerm provider
  # cors {
  #   allowed_origins     = var.cors_allowed_origins # List of allowed origins
  #   support_credentials = false
  # }

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = var.assigned_identity_ids
  }

  site_config {
    application_insights_connection_string        = var.ai_connstring
    container_registry_use_managed_identity       = var.cont_registry_use_mi
    container_registry_managed_identity_client_id = var.acr_mi_client_id
    ftps_state                                    = var.ftps_state
    minimum_tls_version                           = var.minimum_tls_version


    application_stack {
      docker {
        registry_url = var.acr_login_server
        image_name   = var.image_name
        image_tag    = var.image_tag
      }
    }

    use_32_bit_worker = var.worker_32bit
  }

  storage_account_name       = var.sa_name
  storage_account_access_key = var.sa_prm_key

  tags = var.tags
}
