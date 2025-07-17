terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = "4.34.0"
      configuration_aliases = [azurerm.hub]
    }
    azapi = {
      source  = "azure/azapi"
      version = "2.5.0"
    }
  }
}
