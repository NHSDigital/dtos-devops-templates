
variable "name" {
  type        = string
  description = "Initiative name."
}

variable "display_name" {
  type        = string
  description = "Initiative display name."
}

variable "description" {
  type        = string
  default     = ""
  description = "Description of the initiative."
}

variable "policy_type" {
  type        = string
  default     = "custom"
  description = "Type of the initiative, whether it is custom or pre-existing."
  validation {
    condition = contains(["custom", "builtin"], var.policy_type)
    error_message = "PolicyType must be on of: custom, builtin"
  }
}

variable "policy_definitions" {
  type = list(object({
    id           = string
    parameters   = optional(any)
    reference_id = optional(string)
  }))
  default = []
  description = "List of policy definitions included in the initiative."
}
