variable "regions" {
  type = map(object({
    address_space     = optional(string)
    is_primary_region = bool
    connect_peering   = optional(bool, false)
    subnets = optional(map(object({
      cidr_newbits               = string
      cidr_offset                = string
      create_nsg                 = optional(bool, true) # defaults to true
      name                       = optional(string)     # Optional name override
      delegation_name            = optional(string)
      service_delegation_name    = optional(string)
      service_delegation_actions = optional(list(string))
    })))
  }))
}

variable "service_bus" {
  description = "Configuration for Service Bus namespaces and their topics"
  type = map(object({
    namespace_name   = optional(string)
    capacity         = number
    sku_tier         = string
    max_payload_size = string
    topics = map(object({
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
      topic_name                              = optional(string)
    }))
  }))
}

