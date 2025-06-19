variable "name" {
  description = "The name of the nsg."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,78}[a-zA-Z0-9.]+$", var.name))
    error_message = "The Azure Network Security Group name must be between 1 and 80 characters, start with an alphanumeric character, end with an alphanumeric character, or period, and can contain alphanumeric characters, periods, underscores and hyphens."
  }
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the NSG. Changing this forces a new resource to be created."
}

variable "location" {
  type        = string
  description = "location"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags to be applied throughout the deployment."
  default     = {}
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "id of the log analytics workspace to send resource logging to via diagnostic settings"
}

variable "monitor_diagnostic_setting_network_security_group_enabled_logs" {
  type        = list(string)
  description = "Controls what logs will be enabled for the NSG"
}

variable "nsg_rules" {
  description = "Additional NSG rules for securing subnets (Optional)."
  type = list(object({
    name                         = string
    priority                     = number
    direction                    = string
    access                       = string
    protocol                     = string
    source_port_range            = optional(string)
    source_port_ranges           = optional(list(string))
    destination_port_range       = optional(string)
    destination_port_ranges      = optional(list(string))
    source_address_prefix        = optional(string)
    source_address_prefixes      = optional(list(string))
    destination_address_prefix   = optional(string)
    destination_address_prefixes = optional(list(string))
  }))

  validation {
    condition = length(var.nsg_rules) == 0 || alltrue([
      for rule in var.nsg_rules : (
        rule.name != "" &&
        rule.priority > 99 &&
        contains(["Inbound", "Outbound"], rule.direction) &&
        contains(["Allow", "Deny"], rule.access) &&
        contains(["Tcp", "Udp", "Icmp", "*"], rule.protocol) &&
        # Exclusive or (XOR) logic
        (
          (rule.source_port_range != null && rule.source_port_ranges == null) ||
          (rule.source_port_range == null && rule.source_port_ranges != null)
        ) &&
        (
          (rule.destination_port_range != null && rule.destination_port_ranges == null) ||
          (rule.destination_port_range == null && rule.destination_port_ranges != null)
        ) &&
        (
          (rule.source_address_prefix != null && rule.source_address_prefixes == null) ||
          (rule.source_address_prefix == null && rule.source_address_prefixes != null)
        ) &&
        (
          (rule.destination_address_prefix != null && rule.destination_address_prefixes == null) ||
          (rule.destination_address_prefix == null && rule.destination_address_prefixes != null)
        )
      )
    ])
    error_message = "Each network security group rule must have a valid name, priority, direction (Inbound or Outbound), access (Allow or Deny), protocol (Tcp, Udp, Icmp, or *), source port range or ranges, destination port range or ranges, source address prefix or prefixes, and destination address prefix or prefixes."
  }
}
