variable "capacity" {
  description = "When sku is Premium, capacity can be 1, 2, 4, 8 or 16. When sku is Basic or Standard, capacity must be 0."
  type        = number
  default     = 0
  validation {
    condition = (
      (var.sku_tier == "Premium" && contains([1, 2, 4, 8, 16], var.capacity)) ||
      ((var.sku_tier == "Basic" || var.sku_tier == "Standard") && var.capacity == 0)
    )
    error_message = "Invalid capacity: Premium allows 1, 2, 4, 8 or 16. Basic and Standard must have capacity 0."
  }
}

variable "location" {
  description = "The location/region where the Service Bus namespace will be created."
  type        = string
  default     = "uksouth"
  validation {
    condition     = contains(["uksouth", "ukwest"], var.location)
    error_message = "The location must be either uksouth or ukwest."
  }
}

variable "premium_messaging_partitions" {
  description = "Boolean flag which controls whether to enable the queue to be partitioned across multiple message brokers. Changing this forces a new resource to be created."
  type        = number
  default     = 1
}

variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "partitioning_enabled" {
  description = "Boolean flag which controls whether to enable the queue to be partitioned across multiple message brokers. Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Event Grid. Changing this forces a new resource to be created."
  validation {
    condition     = can(regex("^[-\\w\\._\\(\\)]+$", var.resource_group_name)) && length(var.resource_group_name) > 0
    error_message = "The resource group name must be a non-empty string using only alphanumeric characters, dashes, underscores, periods, or parentheses."
  }
}

variable "servicebus_namespace_name" {
  description = "The name of the Service Bus namespace."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Zq0-9-]{6,49}$", var.servicebus_namespace_name))
    error_message = "The Service Bus namespace name must be between 7 and 50 characters and can contain only letters, numbers, and hyphens. It must start with a letter or number."
  }
}

variable "servicebus_queue_map" {
  type = map(object({
    auto_delete_on_idle                     = optional(string, "P10675199DT2H48M5.4775807S")
    batched_operations_enabled              = optional(bool, false)
    default_message_ttl                     = optional(string, "P10675199DT2H48M5.4775807S")
    duplicate_detection_history_time_window = optional(string)
    partitioning_enabled                    = optional(bool, false)
    max_message_size_in_kilobytes           = optional(number, 1024)
    max_size_in_megabytes                   = optional(number, 5120)
    requires_duplicate_detection            = optional(bool, false)
    support_ordering                        = optional(bool)
    status                                  = optional(string, "Active")
    queue_name                              = optional(string)
  }))
  default = {}
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

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "private_endpoint_properties" {
  description = "Consolidated properties for the Service Bus Private Endpoint."
  type = object({
    private_dns_zone_ids                 = optional(list(string), [])
    private_endpoint_enabled             = optional(bool, false)
    private_endpoint_subnet_id           = optional(string, "")
    private_endpoint_resource_group_name = optional(string, "")
    private_service_connection_is_manual = optional(bool, false)
  })

  validation {
    condition = (
      can(var.private_endpoint_properties == null) ||
      can(var.private_endpoint_properties.private_endpoint_enabled == false) ||
      can((length(var.private_endpoint_properties.private_dns_zone_ids) > 0 &&
        length(var.private_endpoint_properties.private_endpoint_subnet_id) > 0
        )
      )
    )
    error_message = "Both private_dns_zone_ids and private_endpoint_subnet_id must be provided if private_endpoint_enabled is true."
  }
}
