variable "name" {
  description = "The name of the PostgreSQL Flexible Server."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the PostgreSQL Flexible Server."
  type        = string
}

variable "location" {
  description = "The location/region where the PostgreSQL Flexible Server is created."
  type        = string
}

variable "backup_retention_days" {
  description = "The number of days to retain backups for the PostgreSQL Flexible Server."
  type        = number
}

variable "geo_redundant_backup_enabled" {
  description = "Whether geo-redundant backup is enabled for the PostgreSQL Flexible Server."
  type        = bool
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
}

# /* --------------------------------------------------------------------------------------------------
#   Auditing and Diagnostics Variables
# -------------------------------------------------------------------------------------------------- */
# variable "monitor_diagnostic_setting_database_enabled_logs" {
#   type        = list(string)
#   description = "Controls what logs will be enabled for the database"
# }

# variable "monitor_diagnostic_setting_database_metrics" {
#   type        = list(string)
#   description = "Controls what metrics will be enabled for the database"
# }
