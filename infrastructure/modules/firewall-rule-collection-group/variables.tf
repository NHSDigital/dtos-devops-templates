variable "name" {
  description = "The name of the firewall network rule."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,80}$", var.name))
    error_message = "The name must be a maximum of 80 characters and contain only alphanumeric characters."
  }
}

variable "firewall_policy_id" {
  description = "The ID of the Firewall Policy."
  type        = string
}

variable "priority" {
  description = "The priority of the rule."
  type        = number
  validation {
    condition     = var.priority >= 100 && var.priority <= 65000
    error_message = "The priority must be between 100 and 65000."
  }
}


variable "application_rule_collection" {
  description = "List of application rule collections"
  type = list(object({
    name      = string
    priority  = number
    action    = string
    rule_name = string
    protocols = list(object({
      type = string
      port = number
    }))
    source_addresses  = list(string)
    destination_fqdns = list(string)
  }))

}

variable "network_rule_collection" {
  description = "List of network rule collections"
  type = list(object({
    name                  = string
    priority              = number
    action                = string
    rule_name             = string
    source_addresses      = list(string)
    destination_addresses = list(string)
    protocols             = list(string)
    destination_ports     = list(string)
  }))
}

variable "nat_rule_collection" {
  description = "List of nat rule collections"
  type = list(object({
    name                = string
    priority            = number
    action              = string
    rule_name           = string
    translated_address  = string
    source_addresses    = list(string)
    destination_address = string
    protocols           = list(string)
    destination_ports   = list(string)
    translated_port     = string
  }))
}
