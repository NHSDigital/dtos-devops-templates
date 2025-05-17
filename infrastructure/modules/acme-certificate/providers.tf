terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      configuration_aliases = [
        azurerm.dns_public,
        azurerm.dns_private
      ]
    }
  }
}
