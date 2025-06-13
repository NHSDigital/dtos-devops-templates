# cdn-frontdoor-profile

A Terraform module to create the parent resource for up to 25 [Front Door Endpoint](../cdn-frontdoor/README.md) configurations.

The Premium SKU (required for private networking) attracts a considerable standing charge, so it is preferable to deploy as shared infrastructure (e.g. using a Live/Non-live pattern, with environments cohabiting). This is why the profile has been separated into its own module, since it is likely to be deployed separately from the individual endpoint configurations.

> ⚠️ All Front Door configuration from the Profile downwards must reside within the same Azure subscription.

## Features
- Customer managed certificates are supported by this module, needed for apex domain use. Certificates using elliptic curve cryptography are [not yet supported by Front Door](https://learn.microsoft.com/en-us/azure/frontdoor/standard-premium/how-to-configure-https-custom-domain?tabs=powershell#use-your-own-certificate). The Key Vault storing the certificate must also reside in the same Azure subscription as Front Door. You may use the [acme-certificate](../acme-certificate/README.md) module to create a compliant certificate (`key_type = 4096`).

## Example Usage

```hcl
module "frontdoor_profile" {
  for_each = local.frontdoor_profiles

  source = "../../dtos-devops-templates/infrastructure/modules/cdn-frontdoor-profile"

  log_analytics_workspace_id                        = module.log_analytics_workspace_hub[local.primary_region].id
  monitor_diagnostic_setting_frontdoor_enabled_logs = local.monitor_diagnostic_setting_frontdoor_enabled_logs
  monitor_diagnostic_setting_frontdoor_metrics      = local.monitor_diagnostic_setting_frontdoor_metrics
  metric_enabled                                    = var.diagnostic_settings.metric_enabled

  # Front Door Profile is a global resource, hence the use of primary_region Key Vault
  name                = "${module.config[local.primary_region].names.front-door-profile}-${each.value.short_name}"
  resource_group_name = azurerm_resource_group.rg_project["${each.key}-${local.primary_region}"].name
  sku_name            = each.value.frontdoor_profile.sku_name
  secrets             = { for k in each.value.frontdoor_profile.secrets : k => module.acme_certificate[k].key_vault_certificate[local.primary_region].versionless_id }

  identity = each.value.frontdoor_profile.identity

  tags = var.tags
}
```

## Terraform documentation
For the list of inputs, outputs, resources... check the [terraform module documentation](tfdocs.md).
