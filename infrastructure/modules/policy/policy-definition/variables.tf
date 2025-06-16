
variable "policy_name" {
  type        = string
  description = "Policy definition name."
}

variable "display_name" {
  type        = string
  description = "Display name for the policy."
}

variable "description" {
  type        = string
  default     = ""
  description = "Description of the policy."
}

variable "mode" {
  type        = string
  default     = "All"
  description = "Determines which resource types are evaluated for a policy definition"
  validation {
    condition = contains([
      # Resource Manager Modes
      "All", "Indexed",
      # Resource Provider Modes
      "Microsoft.ContainerService.Data",
      "Microsoft.CustomerLockbox.Data",
      "Microsoft.DataCatalog.Data",
      "Microsoft.KeyVault.Data",
      "Microsoft.Kubernetes.Data",
      "Microsoft.MachineLearningServices.Data",
      "Microsoft.Network.Data",
    "Microsoft.Synapse.Data"], var.mode)
    error_message = "Mode must be one of: (Resource Provider Modes) All, Indexed. (Resource Provider Modes) Microsoft.ContainerService.Data, Microsoft.CustomerLockbox.Data, Microsoft.DataCatalog.Data, Microsoft.KeyVault.Data, Microsoft.Kubernetes.Data, Microsoft.MachineLearningServices.Data, Microsoft.Network.Data and Microsoft.Synapse.Data"
  }
}

variable "metadata" {
  type        = map(any)
  default     = {}
  description = "Optional additional metadata for the policy definition."
}

variable "policy_conditions"{
  type        = list(any)
  default     = []
  description = <<EOT
    List of condition objects used in the `if.anyOf` block of the policy rule.
    If not set, expects a local called `local.policy_conditions` to be used instead.
  EOT
}

variable "policy_effect"{
  type = string
  description = "The effect to be applied by this policy"
  validation {
      condition = contains([
        "deny", "audit", "modify", "denyAction", "append",
        "auditIfNotExists", "deployIfNotExists", "disabled"
      ], var.policy_effect)
      error_message = "PolicyEffect must be one of: append, audit, auditIfNotExists, deny, denyAction, deployIfNotExists, disabled, modify"
    }
}

variable "policy_operations"{
  type        = list(any)
  default     = []
  description = <<EOT
    List of `then.details.operations` objects used in the policy rule.
    If not set, expects a local called `local.policy_operations` to be used instead.
  EOT
}

variable "parameters" {
  type        = map(any)
  default     = {}
  description = "Optional parameters to pass into the policy (used with `policy_rule`)."
}

variable "policy_type" {
  type        = string
  default     = "Custom"
  description = "Type of policy."
  validation {
    condition     = contains(["BuiltIn", "Custom", "NotSpecified", "Static"], var.policy_type)
    error_message = "PolicyType must be one of: BuiltIn, Custom, NotSpecified, Static"
  }
}
