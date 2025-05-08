# key is "${cert_key}-${region}"
output "key_vault_certificates" {
  value = {
    for k, v in local.letsencrypt_certs_map : k => {
      name                  = data.azurerm_key_vault_certificate.letsencrypt[k].name
      naming_key            = v.cert_key
      subject               = v.cert_subject
      location              = v.region
      id                    = data.azurerm_key_vault_certificate.letsencrypt[k].id
      versionless_id        = data.azurerm_key_vault_certificate.letsencrypt[k].versionless_id
      versionless_secret_id = data.azurerm_key_vault_certificate.letsencrypt[k].versionless_secret_id
    }
  }
}

output "key_vault_certificate_pfx_blobs" {
  value = {
    for k, v in local.letsencrypt_certs_map : k => {
      name           = data.azurerm_key_vault_secret.pfx_blob[k].name
      naming_key     = v.cert_key
      subject        = v.cert_subject
      location       = v.region
      id             = data.azurerm_key_vault_secret.pfx_blob[k].id
      versionless_id = data.azurerm_key_vault_secret.pfx_blob[k].versionless_id
    }
  }
}
