
variable "policy_assignment_scope" {
  type = string
  description = "The scope at which this assignment is assigned"
}

variable "policy_assignment_principal_id" {
  type = string
  description = "The identifier of a specific service principal to use for the policy assignment"
}
