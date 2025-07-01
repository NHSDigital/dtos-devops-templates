variable "assignments" {
  description = <<EOT
List of role assignments to apply to the principal. Each entry must have:
  - role_definition_name (e.g. "Key Vault Secrets User")
  - scope (e.g. a resource ID)
EOT

  type = list(object({
    scope                = string
    role_definition_name = string
  }))
  default = []
}

variable "enable_global_rbac" {
  description = "True to enable RBAC assignments for the global User Assigned Managed Identity, False otherwise"
  type        = bool
  default     = false
}

variable "environment" {
  type        = string
  description = "A code of the environment in which to create the user-assigned identity and role assignments."
}

variable "identity_prefix" {
  type        = string
  description = "A prefix to use when creating a user-assigned identity"
  default     = "uami-global"
}

variable "principal_id" {
  description = "The principal ID (e.g., user, group, or service principal) to which the role will be assigned."
  type        = string
  default     = null
}

variable "location" {
  type        = string
  description = "The region where the user assigned identity must be created."
}

variable "resource_group" {
  type        = string
  description = "A name of a resource group to locate this user assigned identity."
}


variable "tags" {
  type        = map(string)
  description = "Resource tags to be applied throughout the deployment."
  default     = {}
}

variable "key_vault_ids" {
  type = map(object({
    key_vault_id = string
  }))
  description = "A collection of key vault resources to apply a user assigned managed identity and default roles"
  default = {}
}

variable "storage_ids" {
  type = map(object({
    storage_account_id = string
  }))
  description = "A collection of storage resources to apply a user assigned managed identity and default roles"
  default = {}
}

variable "sql_server_ids" {
  type = map(object({
    sql_server_id = string
  }))
  description = "A collection of sql server resources to apply a user assigned managed identity and default roles"
  default = {}
}

variable "function_ids" {
  type = map(object({
    function_app_id = string
  }))
  description = "A collection of Function App resources to apply a user assigned managed identity and default roles"
  default = {}
}
