variable "service_bus_subscriptions" {
  description = "Configuration for event grid subscriptions"
  type = object({
    subscriber_config = map(object({
      subscription_name       = string
      namespace_name          = optional(string)
      topic_name              = string
      subscriber_functionName = string
    }))
  })
}

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
