variable "remediation_name" {
  type        = string
  description = "The policy remediation name."
}

variable "policy_assignment_id" {
  type        = string
  description = "The identifier of a specific policy assignment."
}

variable "resource_id" {
  type        = string
  description = "The identifier of a specific resource to apply this policy onto."
  default     = null
}
