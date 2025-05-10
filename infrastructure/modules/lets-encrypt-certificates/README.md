# lets-encrypt-certificates

A Terraform module to obtain publicly trusted SSL certificates from the Let's Encrypt Certificate Authority. This module addresses the lack of a native, integrated certificate management solution in Azure, equivalent to AWS Certificate Manager.

## Features
- Integrates the Python [Certbot](https://github.com/certbot/certbot) package, since pip3 conveniently manages the extensive dependencies.
- Wildcard certificate support.
- Rolls up the configuration and log files into a persistent state.
- State storage in Azure Storage Account.
- Seamless certificate renewals within 30 days of expiry.
- Automates the public DNS challenge TXT records via [certbot‑dns‑azure](https://docs.certbot-dns-azure.co.uk/en/latest/) plugin.
- Supports DNS challenges for nested subdomains without needing to create delegated DNS zones (e.g. _www.private.domain.com_ challenge via _domain.com_)
- Certificates are stored in Azure Key Vault as Certificate objects, skipped if thumbprint remains unchanged.
- A fallback .pfx file is also stored as a base64-encoded secret for cases where Key Vault Certificate objects cannot be consumed directly.
- Multiple subscription support (hub/spoke model).
- Multiple region support.

## Requirements
- A Storage Account container named `certbot-state`.
- Let's Encrypt does not allow concurrent certificate requests from a single account, so this module obtains all specified certificates serially in a single execution. Avoid using the for_each meta-argument or running multiple instances in parallel.
- A bash shell.
- This module runs as a null resource, so it needs its own authentication with Azure since it launches in the context of the shell which launched Terraform. The recommended approach for CI/CD pipelines is to launch Terraform from an authenticated shell. e.g. in Azure DevOps use [AzureCLI@2 task](https://learn.microsoft.com/en-us/azure/devops/pipelines/tasks/reference/azure-cli-v2?view=azure-pipelines) with:
  ```yaml
  addSpnToEnvironment: true
  scriptType: bash
  ```
  This will result in the parent shell being authenticated with Azure (for the null resource), and Terraform will use those same session credentials exported via environment variables.

## Example Usage

```terraform
module "lets_encrypt_certificates" {
  source = "../../dtos-devops-templates/infrastructure/modules/lets-encrypt-certificates"

  certificates = {
    nationalscreening_wildcard = "*.nationalscreening.nhs.uk"
    screening_wildcard         = "*.screening.nhs.uk"
    screening_www              = "www.screening.nhs.uk"
  }

  dns_zone_names = {
    nationalscreening = "nationalscreening.nhs.uk"
    screening         = "screening.nhs.uk"
  }

  dns_zone_resource_group_name = var.dns_zone_rg_name_public
  environment                  = var.environment
  email                        = var.LETS_ENCRYPT_CONTACT_EMAIL
  key_vaults                   = module.key_vault # a map of Azure Key Vault objects, keyed by region name
  storage_account_name_hub     = var.HUB_BACKEND_AZURE_STORAGE_ACCOUNT_NAME
  subscription_id_hub          = var.SUBSCRIPTION_ID_HUB
  subscription_id_target       = var.SUBSCRIPTION_ID_TARGET
}
```

## Example Output

Note the compound key `${naming_key}-${region}`:

```terraform
key_vault_certificates = {
  "nationalscreening_wildcard-uksouth" = {
    "id"                    = "redacted"
    "location"              = "uksouth"
    "name"                  = "wildcard-nationalscreening-nhs-uk"
    "naming_key"            = "nationalscreening_wildcard"
    "pfx_blob_secret_name"  = "pfx-wildcard-nationalscreening-nhs-uk"
    "subject"               = "*.nationalscreening.nhs.uk"
    "versionless_id"        = "redacted"
    "versionless_secret_id" = "redacted"
  }
  "screening_wildcard-uksouth" = {
    "id"                    = "redacted"
    "location"              = "uksouth"
    "name"                  = "wildcard-screening-nhs-uk"
    "naming_key"            = "screening_wildcard"
    "pfx_blob_secret_name"  = "pfx-wildcard-screening-nhs-uk"
    "subject"               = "*.screening.nhs.uk"
    "versionless_id"        = "redacted"
    "versionless_secret_id" = "redacted"
  }
  "screening_www-uksouth" = {
    "id"                    = "redacted"
    "location"              = "uksouth"
    "name"                  = "www-screening-nhs-uk"
    "naming_key"            = "screening_www"
    "pfx_blob_secret_name"  = "pfx-www-screening-nhs-uk"
    "subject"               = "www.screening.nhs.uk"
    "versionless_id"        = "redacted"
    "versionless_secret_id" = "redacted"
  }
}
```

## Terraform documentation
For the list of inputs, outputs, resources... check the [terraform module documentation](tfdocs.md).
