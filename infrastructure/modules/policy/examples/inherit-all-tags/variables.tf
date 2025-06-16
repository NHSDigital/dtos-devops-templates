variable "policy_name" {
  type        = string
  description = "Name of the custom policy definition"
}

variable "scope" {
  type        = string
  description = "Scope to assign the policy (e.g., Resource Group ID)"
}

variable "tags" {
  type        = list(string)
  description = "List of tag to enforce inheritance to contained resources"
  validation {
    condition     = length(var.tags) <= 32
    error_message = "A maximum of 32 tags can be inherited by this policy."
  }
}
