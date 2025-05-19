# This module is now deprecated - replaced by module 'acme-certificate'.

# This INI file is used by the Azure DNS plugin for certbot to allow automation of the DNS TXT record challenges
resource "local_file" "certbot_ini_file" {
  filename        = ".terraform/certbot_dns.ini"
  file_permission = "0600"
  content         = <<EOT
dns_azure_use_cli_credentials = true
dns_azure_environment = "AzurePublicCloud"
%{for name, zone in var.dns_zone_names~}
dns_azure_zone${index(keys(var.dns_zone_names), name) + 1} = ${zone}:${data.azurerm_dns_zone.lookup[name].id}
%{endfor~}
EOT
}

# Run Python3 certbot using Azure CLI auth for the DNS challenge, for cert storage in Key Vault(s), and to store the certbot state in Azure Storage Account
resource "null_resource" "letsencrypt_cert" {
  # cannot use for_each since certbot cannot make concurrent requests
  triggers = {
    always_run = "${timestamp()}"
    email      = var.email
    st         = var.subscription_id_target
    sh         = var.subscription_id_hub
    sa         = var.storage_account_name_hub
    en         = var.environment
    key_vaults = join(" ", [for k, v in var.key_vaults : format("-kv %s", v.key_vault_name)])
    domains    = join(" ", values(var.certificates))
  }

  provisioner "local-exec" {
    when    = create
    quiet   = true
    command = "${path.module}/scripts/certbot.sh -e ${self.triggers.email} -st ${self.triggers.st} -sh ${self.triggers.sh} -sa ${self.triggers.sa} -en ${self.triggers.en} ${self.triggers.key_vaults} ${self.triggers.domains}"
  }

  depends_on = [
    local_file.certbot_ini_file
  ]
}
