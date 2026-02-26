variable "name" {
  description = "The name of the Azure Bastion host."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9.-]{0,78}[a-zA-Z0-9]$", var.name))
    error_message = "The Bastion host name must be between 2 and 80 characters, start and end with an alphanumeric character, and can contain alphanumeric characters, hyphens, and periods."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Bastion host."
  type        = string
}

variable "location" {
  description = "The location/region where the Bastion host will be created."
  type        = string
  default     = "uksouth"
  validation {
    condition     = contains(["uksouth", "ukwest"], var.location)
    error_message = "The location must be either uksouth or ukwest."
  }
}

variable "sku" {
  description = "The SKU tier of the Bastion host. Possible values are Basic, Standard, and Premium. Standard is recommended for most production workloads; Premium adds session recording and private-only deployment. Developer SKU is not supported by this module as it does not use a public IP or dedicated subnet."
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "The SKU must be one of: Basic, Standard, Premium. Developer SKU is not supported by this module."
  }
}

variable "subnet_id" {
  description = "The ID of the AzureBastionSubnet in which the Bastion host will be deployed."
  type        = string
}

variable "public_ip_name" {
  description = "The name of the public IP address resource created for the Bastion host."
  type        = string
}

variable "copy_paste_enabled" {
  description = "Is copy/paste feature enabled for the Bastion host."
  type        = bool
  default     = true
}

variable "file_copy_enabled" {
  description = "Is file copy feature enabled for the Bastion host. Requires Standard SKU or higher."
  type        = bool
  default     = false
}

variable "ip_connect_enabled" {
  description = "Is IP connect feature enabled for the Bastion host. Requires Standard SKU or higher."
  type        = bool
  default     = false
}

variable "tunneling_enabled" {
  description = "Is tunneling (native client support) feature enabled for the Bastion host. Enables native SSH/RDP client connections via az network bastion ssh/rdp. Recommended for Standard SKU or higher."
  type        = bool
  default     = false
}

variable "shareable_link_enabled" {
  description = "Is shareable link feature enabled for the Bastion host. Requires Standard SKU or higher."
  type        = bool
  default     = false
}

variable "scale_units" {
  description = "The number of scale units for the Bastion host. Each unit supports ~20 concurrent RDP / ~40 concurrent SSH sessions. Must be between 2 and 50 for Standard/Premium SKU; Basic is fixed at 2."
  type        = number
  default     = 2
  validation {
    condition     = var.scale_units >= 2 && var.scale_units <= 50
    error_message = "scale_units must be between 2 and 50."
  }
}

variable "zones" {
  description = "Availability zones for the public IP address. Use [\"1\", \"2\", \"3\"] for zone-redundant deployment, which is recommended for production environments. An empty list deploys with no zone redundancy."
  type        = list(string)
  default     = []
  validation {
    condition     = length(var.zones) <= 3
    error_message = "A maximum of 3 availability zones can be specified."
  }
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace to send diagnostic logs to."
  type        = string
}

variable "monitor_diagnostic_setting_bastion_enabled_logs" {
  description = "List of log categories to enable for the Bastion diagnostic setting (e.g. [\"BastionAuditLogs\"])."
  type        = list(string)
}

variable "monitor_diagnostic_setting_bastion_metrics" {
  description = "List of metric categories to enable for the Bastion diagnostic setting (e.g. [\"AllMetrics\"])."
  type        = list(string)
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
