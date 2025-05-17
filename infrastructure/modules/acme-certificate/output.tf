output "key_vault_certificate" {
  value = {
    for k, v in azurerm_key_vault_certificate.acme : k => {
      name                  = v.name
      naming_key            = var.certificate_name
      subject               = var.certificate.common_name
      location              = k
      id                    = v.id
      versionless_id        = v.versionless_id
      versionless_secret_id = v.versionless_secret_id
      
      # directly referencing the secret name causes the entire output to be classed as sensitive
      pfx_blob_secret_name  = "pfx-${replace(replace(var.certificate.common_name, "*.", "wildcard-"), ".", "-")}"
    }
  }
}

output "pfx_password" {
  value     = random_password.pfx.result
  sensitive = true
}
