variable "name" {
  description = "The name of the Azure Relay Hybrid Connection."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9]([a-zA-Z0-9-._]{0,258}[a-zA-Z0-9])?$", var.name))
    error_message = "The hybrid connection name must be 1-260 characters, start and end with an alphanumeric character, and can only contain letters, numbers, hyphens, underscores, and periods."
  }
}

variable "relay_namespace_name" {
  description = "The name of the Azure Relay namespace in which to create the Hybrid Connection."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group containing the Azure Relay namespace."
  type        = string
}

variable "requires_client_authorization" {
  description = "Whether client authorization is required for this Hybrid Connection."
  type        = bool
  default     = true
}

variable "user_metadata" {
  description = "User metadata string for the Hybrid Connection."
  type        = string
  default     = null
}

variable "authorization_rules" {
  description = "A map of authorization rules to create for the Hybrid Connection."
  type = map(object({
    listen = optional(bool, false)
    send   = optional(bool, false)
    manage = optional(bool, false)
  }))
  default = {}

  validation {
    condition = alltrue([
      for name, rule in var.authorization_rules :
      can(regex("^[a-zA-Z0-9]([a-zA-Z0-9-._]{0,254}[a-zA-Z0-9])?$", name))
    ])
    error_message = "Authorization rule names must be 1-256 characters, start and end with an alphanumeric character, and can only contain letters, numbers, hyphens, underscores, and periods."
  }

  validation {
    condition = alltrue([
      for name, rule in var.authorization_rules :
      rule.manage == false || (rule.listen == true && rule.send == true)
    ])
    error_message = "When 'manage' is true, both 'listen' and 'send' must also be true."
  }
}
