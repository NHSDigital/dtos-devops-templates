variable "firewall_name" {
  description = "The name of the firewall."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9_][a-zA-Z0-9-_]{0,253}[a-zA-Z0-9_]$", var.firewall_name))
    error_message = "The Firewall name must be between 1 and 255 characters and can only contain alphanumeric characters, hyphens, and underscores."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the firewall."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,255}$", var.resource_group_name))
    error_message = "The resource group name must be between 1 and 255 characters and can only contain alphanumeric characters, hyphens, and underscores."
  }
}

variable "location" {
  description = "The location/region where the firewall will be created."
  type        = string
  default     = "uksouth"
  validation {
    condition     = contains(["uksouth", "ukwest"], var.location)
    error_message = "The location must be either uksouth or ukwest."
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

/* --------------------------------------------------------------------------------------------------
  Firewall Variables
-------------------------------------------------------------------------------------------------- */

variable "ip_configuration" {
  description = "List of public ips' ids to attach to the firewall."
  type = list(object({
    name                 = string
    public_ip_address_id = string
    firewall_subnet_id   = string
  }))
  default = []

  # Removed for now - need to loop through the public IPs and validate them individually.
  # validation {
  #   condition     = can(regex("^/subscriptions/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}/resourceGroups/[A-Za-z0-9_-]{1,90}/providers/Microsoft.Network/publicIPAddresses/[A-Za-z0-9_-]{1,80}$", var.ip_configuration.public_ip_address_id))
  #   error_message = "The public IP address ID must be a valid public IP address ID."
  # }
}

variable "sku_name" {
  description = "The tier of the SKU."
  type        = string
  default     = "AZFW_VNet"
  validation {
    condition     = contains(["AZFW_Hub", "AZFW_VNet"], var.sku_name)
    error_message = "The SKU tier must be either AZFW_Hub or AZFW_VNet."
  }
}

variable "sku_tier" {
  description = "The tier of the SKU."
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku_tier)
    error_message = "The SKU name must be either Basic, Standard or Premium."
  }
}

variable "zones" {
  description = "Specifies a list of Availability Zones in which this Azure Firewall should be located. Changing this forces a new Azure Firewall to be created."
  type        = list(string)
  default     = null
  validation {
    condition     = length(var.zones) <= 3
    error_message = "The number of zones must be less than or equal to 3."
  }
}

/* --------------------------------------------------------------------------------------------------
  Firewall Policy Variables
-------------------------------------------------------------------------------------------------- */

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

variable "policy_name" {
  description = "The name of the firewall policy"
  type        = string
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
