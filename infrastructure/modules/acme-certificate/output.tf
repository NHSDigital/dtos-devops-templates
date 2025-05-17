output "key_vault_certificate" {
  value = {
    for k, v in azurerm_key_vault_certificate.acme : k => {
      name                  = v.name
      naming_key            = var.certificate_naming_key
      subject               = var.certificate.common_name
      location              = k
      pfx_blob_secret_name  = azurerm_key_vault_secret.acme[k].name
      pfx_password          = random_password.pfx.result
      id                    = v.id
      versionless_id        = v.versionless_id
      versionless_secret_id = v.versionless_secret_id
    }
  }
  sensitive = true
}
