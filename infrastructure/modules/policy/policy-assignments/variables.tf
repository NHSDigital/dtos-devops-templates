variable "assignment_name" {
  type = string
  description = "A short name for this policy assignment"
}

variable "assignment_type"{
  type = string
  default = "resource"
  validation {
    condition = contains(["resource", "resource-group"], var.assignment_type)
    error_message = "AssignmentType must be one of: resource, resource-group"
  }
}

variable "create_remediator_role" {
  type = bool
  default = false
  description = "True to create an associated Policy Contributor role, false otherwise"
}

variable "display_name" {
  type        = string
  description = "Policy assignment display name."
}

variable "description" {
  type        = string
  default     = ""
  description = "Description of the policy assignment."
}

variable "enforce_policy" {
  type = bool
  default = true
  description = "True if this policy should be enforced, false otherwise"
}

variable "enabled_log" {
  type        = list(string)
  description = "True to enable logging, false otherwise"
  default     = []
}

variable "log_analytics_wks_id" {
  type = string
  description = "An identifier of a specific Log Analytics Workspace instance to use"
  default = null
}

variable "policy_definition_id" {
  type        = string
  description = "An identifier of a policy definition to assign."
}

variable "parameters" {
  type        = map(any)
  default     = {}
  description = "Parameters for the policy assignment."
}


variable "policy_assignment_scope" {
  type = string
  description = "The scope at which this assignment is assigned"
}

variable "policy_assignment_principal_id" {
  type = string
  description = "The identifier of a specific service principal to use for the policy assignment"
}

variable "policy_identities" {
  type = list(string)
  description = "A collection of principal identifiers assigned to this policy. Only required if the identity type is 'UserAssigned'"
  default = []
}

variable "policy_location"{
  type = string
  default = "uksouth"
  description = "Defines where the policy will be deployed to. Required if identify is provided."
  validation {
    condition = contains(["uksouth", "ukwest"], var.policy_location)
    error_message = "PolicyLocation must be one of: uksouth, ukwest"
  }
}

variable "resource_id" {
  type = string
  description = "An identifier of a specific resource to apply this policy onto"
  default = null
}

variable "resource_group_id" {
  type = string
  description = "An identifier of a specific resource group to apply this policy onto"
  default = null
}


