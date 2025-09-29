variable "name" {
  description = "The name of the PostgreSQL Flexible Server."
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,61}[a-z0-9]$", var.name))
    error_message = "The Azure PostgreSQL Flexible Server name must be between 3 and 63 characters, start with a lowercase letter, end with a lowercase letter or number, and can contain lowercase letters, numbers, and hyphens."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the PostgreSQL Flexible Server."
  type        = string
}

variable "location" {
  description = "The location/region where the PostgreSQL Flexible Server is created."
  type        = string
}

variable "administrator_login" {
  type    = string
  default = null
}

variable "backup_retention_days" {
  description = "The number of days to retain backups for the PostgreSQL Flexible Server."
  type        = number
}

variable "geo_redundant_backup_enabled" {
  description = "Whether geo-redundant backup is enabled for the PostgreSQL Flexible Server."
  type        = bool
}

variable "key_vault_id" {
  description = "ID of the Key Vault in which to store the Admin password, if one is created."
  type        = string
  default     = null
}

variable "key_vault_admin_pwd_secret_name" {
  description = "Key Vault secret name in which to store the Admin password, if one is created."
  type        = string
  default     = null
}

variable "password_auth_enabled" {
  type    = bool
  default = false
}

variable "postgresql_admin_object_id" {
  description = "The object ID of the PostgreSQL Active Directory administrator."
  type        = string
}

variable "postgresql_admin_principal_name" {
  description = "The principal name of the PostgreSQL Active Directory administrator."
  type        = string
}

variable "postgresql_admin_principal_type" {
  description = "The principal type of the PostgreSQL Active Directory administrator."
  type        = string
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled for the PostgreSQL Flexible Server."
  type        = bool
  default     = false
}
variable "admin_identities" {
  description = "List of managed identities modules with admin access to the postgres server. The managed identity must have the Directory.Read.All permission."
  type        = list(any)
  default     = []
}

variable "sku_name" {
  # See: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server#sku_name-2
  description = "The SKU name for the PostgreSQL Flexible Server."
  type        = string
}

variable "storage_mb" {
  # See: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server#storage_mb-2
  description = "The storage size in MB for the PostgreSQL Flexible Server."
  type        = number
  default     = 32768

  validation {
    condition     = contains([32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4193280, 4194304, 8388608, 16777216, 33553408], var.storage_mb)
    error_message = "The storage size must be one of the following: 32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4193280, 4194304, 8388608, 16777216, 33553408."
  }
}

variable "storage_tier" {
  # See defaults: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server#storage_tier-defaults-based-on-storage_mb
  description = "The storage tier for the PostgreSQL Flexible Server."
  type        = string
  default     = "P4"

  validation {
    condition     = contains(["P4", "P6", "P10", "P15", "P20", "P30", "P40", "P50", "P60", "P70", "P80"], var.storage_tier)
    error_message = "The storage tier must be one of the following: P4, P6, P10, P15, P20, P30, P40, P50, P60, P70, P80."
  }
}

variable "server_version" {
  description = "The version of the PostgreSQL server."
  type        = string
  default     = "16"

  validation {
    condition     = contains(["11", "12", "13", "14", "15", "16"], var.server_version)
    error_message = "The server version must be one of the following: 11, 12, 13, 14, 15, 16."
  }
}

variable "tenant_id" {
  description = "The tenant ID for the Azure Active Directory."
  type        = string
}

variable "zone" {
  # See: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server#zone-2
  description = "The availability zone for the PostgreSQL Flexible Server. Azure will automatically assign an Availability Zone if one is not specified."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the PostgreSQL Flexible Server."
  type        = map(string)
  default     = {}
}

# Databases
variable "databases" {
  description = "A map of databases to create on the PostgreSQL Flexible Server."
  type = map(object({
    collation   = string
    charset     = string
    max_size_gb = number
    name        = string
  }))
}

# Server configurations
variable "postgresql_configurations" {
  description = "A map of PostgreSQL configurations to apply to the PostgreSQL Flexible Server."
  type        = map(string)
  default     = {}
}

# Private Endpoint Properties
variable "private_endpoint_properties" {
  description = "Consolidated properties for the PostgreSql Private Endpoint."
  type = object({
    private_dns_zone_ids_postgresql      = optional(list(string), [])
    private_endpoint_enabled             = optional(bool, false)
    private_endpoint_subnet_id           = optional(string, "")
    private_endpoint_resource_group_name = optional(string, "")
    private_service_connection_is_manual = optional(bool, false)
  })

  validation {
    condition = (
      can(var.private_endpoint_properties == null) ||
      can(var.private_endpoint_properties.private_endpoint_enabled == false) ||
      can((length(var.private_endpoint_properties.private_dns_zone_ids_postgresql) > 0 &&
        length(var.private_endpoint_properties.private_endpoint_subnet_id) > 0
        )
      )
    )
    error_message = "Both private_dns_zone_ids and private_endpoint_subnet_id must be provided if private_endpoint_enabled is true."
  }
}

/* --------------------------------------------------------------------------------------------------
  Auditing and Diagnostics Variables
-------------------------------------------------------------------------------------------------- */
variable "log_analytics_workspace_id" {
  type        = string
  description = "id of the log analytics workspace to send resource logging to via diagnostic settings"
}

variable "monitor_diagnostic_setting_postgresql_server_enabled_logs" {
  type        = list(string)
  description = "Controls what logs will be enabled for the sql server"
}

variable "monitor_diagnostic_setting_postgresql_server_metrics" {
  type        = list(string)
  description = "Controls what metrics will be enabled for the sql server"
}

variable "alert_window_size" {
  type     = string
  nullable = false
  default  = "PT5M"
  validation {
    condition     = contains(["PT1M", "PT5M", "PT15M", "PT30M", "PT1H", "PT6H", "PT12H"], var.alert_window_size)
    error_message = "The alert_window_size must be one of: PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H"
  }
  description = "The period of time that is used to monitor alert activity e.g. PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H. The interval between checks is adjusted accordingly."
}

variable "enable_monitoring" {
  description = "Whether monitoring and alerting is enabled for the PostgreSQL Flexible Server."
  type        = bool
}

variable "action_group_id" {
  type        = string
  description = "ID of the action group to notify."
}

variable "alert_memory_threshold" {
  type    = number
  description = "If alerting is enabled this will control what the memory threshold will be, default will be 80."
  default = 80
}

variable "azure_storage_threshold" {
  type    = number
  description = "If alerting is enabled this will control what the storage threshold will be, default will be 80."
  default = 80
}

variable "azure_cpu_threshold" {
  type        = number
  description = "If alerting is enabled this will control what the cpu threshold will be, default will be 80."
  default     = 80
}

locals {
  alert_frequency_map = {
    PT5M  = "PT1M"
    PT15M = "PT1M"
    PT30M = "PT1M"
    PT1H  = "PT1M"
    PT6H  = "PT5M"
    PT12H = "PT5M"
  }
  alert_frequency = local.alert_frequency_map[var.alert_window_size]
}
