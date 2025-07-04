variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Event Grid. Changing this forces a new resource to be created."
}

variable "location" {
  type        = string
  description = "The location/region where the Event Grid is created."
}

variable "inbound_ip_rules" {
  description = "List of inbound IP rules"
  type = list(object({
    ip_mask = string
    action  = string
  }))
  default = []
}

variable "identity_type" {
  type        = string
  description = "The identity type of the Event Grid."
}

variable "public_network_access_enabled" {
  type        = string
  default     = false
  description = "Whether or not public network access is allowed for Event Grid."
}

variable "topic_name" {
  description = "The name of the Event Grid topic."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9_][a-zA-Z0-9-_]{0,48}[a-zA-Z0-9_]$", var.topic_name))
    error_message = "The Event Grid Topic name must be between 1 and 50 characters and can only contain alphanumeric characters, hyphens, and underscores."
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the Event Grid topic."
  type        = map(string)
  default     = {}
}

variable "private_endpoint_properties" {
  description = "Consolidated properties for the Event Grid Private Endpoint."
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
