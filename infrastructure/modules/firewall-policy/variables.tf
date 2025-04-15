variable "policy_name" {
  description = "The name of the firewall policy"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9_][a-zA-Z0-9-_]{0,78}[a-zA-Z0-9_]$", var.name))
    error_message = "The Firewall Policy name must be between 1 and 80 characters and can only contain alphanumeric characters, hyphens, and underscores."
  }

}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the firewall policy"
  type        = string
}

variable "location" {
  description = "The location/region where the firewall policy should be created"
  type        = string
  default     = "uksouth"
  validation {
    condition     = contains(["uksouth", "ukwest"], var.location)
    error_message = "The location must be either uksouth or ukwest."
  }
}

variable "sku" {
  description = "The SKU of the firewall policy"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.sku)
    error_message = "The SKU must be either Standard or Premium."
  }
}

variable "threat_intelligence_mode" {
  description = "The threat intelligence mode of the firewall policy"
  type        = string
  default     = "Alert"
  validation {
    condition     = contains(["Alert", "Deny"], var.threat_intelligence_mode)
    error_message = "The threat intelligence mode must be either Alert or Deny."
  }

}
variable "dns_proxy_enabled" {
  description = "Is DNS proxy enabled for the firewall policy"
  type        = bool
  default     = false

}

variable "dns_servers" {
  description = "The DNS servers for the firewall policy"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
