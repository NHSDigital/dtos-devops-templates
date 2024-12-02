variable "name" {
  description = "The name of the Event Hub namespace."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Event Hub namespace."
  type        = string
}

variable "location" {
  description = "The location/region where the Event Hub namespace is created."
  type        = string
}

variable "auth_rule" {
  description = "Authorization rule settings for the Event Hub namespace."
  type = object({
    listen = optional(bool, true)
    send   = optional(bool, false)
    manage = optional(bool, false)
  })
}

variable "auto_inflate" {
  description = "Whether auto-inflate is enabled for the Event Hub namespace."
  type        = bool
}

variable "capacity" {
  description = "Specifies the Capacity / Throughput Units for a Standard SKU namespace. Default capacity has a maximum of 2, but can be increased in blocks of 2 on a committed purchase basis. Defaults to 1."
  type        = number
  default     = 1
}

variable "event_hubs" {
  description = "A map of Event Hubs to create within the namespace."
  type = map(object({
    name              = string
    consumer_group    = string
    partition_count   = number
    message_retention = number
  }))
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "id of the log analytics workspace to send resource logging to via diagnostic settings"
}

variable "monitor_diagnostic_setting_eventhub_enabled_logs" {
  type        = list(string)
  description = "Controls what logs will be enabled for the eventhub"
}

variable "monitor_diagnostic_setting_eventhub_metrics" {
  type        = list(string)
  description = "Controls what metrics will be enabled for the eventhub"
}

variable "minimum_tls_version" {
  description = "The minimum TLS version for the Event Hub namespace."
  type        = string

  validation {
    condition     = contains(["1.2", "1.3"], var.minimum_tls_version)
    error_message = "Minimum TLS version must be one of 1.2 or 1.3"
  }
}

variable "maximum_throughput_units" {
  description = "The maximum throughput units for the Event Hub namespace when auto-inflate is enabled."
  type        = number
}

variable "private_endpoint_properties" {
  description = "Consolidated properties for the Key Vault Private Endpoint."
  type = object({
    private_dns_zone_ids_eventhub        = optional(list(string), [])
    private_endpoint_enabled             = optional(bool, false)
    private_endpoint_subnet_id           = optional(string, "")
    private_endpoint_resource_group_name = optional(string, "")
    private_service_connection_is_manual = optional(bool, false)
  })

  validation {
    condition     = var.private_endpoint_properties.private_endpoint_enabled == false || (length(var.private_endpoint_properties.private_dns_zone_ids_eventhub) > 0 && length(var.private_endpoint_properties.private_endpoint_subnet_id) > 0)
    error_message = "Both private_dns_zone_ids and private_endpoint_subnet_id must be provided if private_endpoint_enabled is true."
  }
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Controls whether data in the account may be accessed from public networks."
  default     = false
}

variable "sku" {
  description = "The SKU for the Event Hub namespace. Note that setting this to Premium will force the creation of a new resource."
  type        = string

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU must be one of Basic, Standard, or Premium."
  }
}

# Now always enabled if the Azure Region supports it
# variable "zone_redundancy" {
#   description = "Whether zone redundancy is enabled for the Event Hub namespace. For eventhub premium namespace, zone_redundant is computed by the api based on the availability zone feature in each region and this value will be overridden"
#   type        = bool
#   default     = true
# }

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
