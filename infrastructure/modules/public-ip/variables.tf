variable "name" {
  description = "The name of the public IP address."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9.-]{0,78}[a-zA-Z0-9]$", var.name))
    error_message = "The Public IP Address name must be between 1 and 80 characters, start with an alphanumeric character, end with an alphanumeric character, and can contain alphanumeric characters, hyphens, and periods."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the public IP address."
  type        = string
}

variable "location" {
  description = "The location/region where the public IP address will be created."
  type        = string
  default     = "uksouth"
  validation {
    condition     = contains(["uksouth", "ukwest"], var.location)
    error_message = "The location must be either uksouth or ukwest."
  }
}

variable "allocation_method" {
  description = "The allocation method for the public IP address."
  type        = string
  default     = "Static"
  validation {
    condition     = contains(["Static", "Dynamic"], var.allocation_method)
    error_message = "The allocation method must be either Static or Dynamic."
  }
}

variable "ddos_protection_mode" {
  description = "The DDoS protection plan mode."
  type        = string
  default     = "VirtualNetworkInherited"
  validation {
    condition     = contains(["Disabled", "Enabled", "VirtualNetworkInherited"], var.ddos_protection_mode)
    error_message = "The DDoS protection plan mode must be either Disabled, Enabled or VirtualNetworkInherited."
  }
}

variable "domain_name_label" {
  description = "The domain name label for the public IP address."
  type        = string
  default     = null
}

variable "sku" {
  description = "The SKU of the public IP address."
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard"], var.sku)
    error_message = "The SKU must be either Basic or Standard."
  }
}

variable "zones" {
  description = "A list of availability zones which the public IP address should be allocated in."
  type        = list(string)
  default     = []
  validation {
    condition     = length(var.zones) <= 3
    error_message = "The public IP address can only be allocated in up to 3 availability zones."
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
