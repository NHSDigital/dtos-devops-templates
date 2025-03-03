variable "name" {
  type = string
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the SQL Server. Changing this forces a new resource to be created."
}

variable "location" {
  type        = string
  description = "The location/region where the SQL Server is created."
}

/* --------------------------------------------------------------------------------------------------
  SQL Server Variables
-------------------------------------------------------------------------------------------------- */

# fw rules
variable "firewall_rules" {
  type = map(object({
    start_ip_address = optional(string, "")
    end_ip_address   = optional(string, "")
  }))
  description = "If the FW rule enabling Azure Services Passthrough should be deployed."
  default     = {}
}

# identity
variable "ad_auth_only" {
  type        = bool
  description = "Specifies whether only AD Users and administrators can be used to login, or also local database users."
}

variable "sql_admin_group_name" {
  type        = string
  description = "Name of the Entra ID group with permissions to manage the SQL Server"
}

variable "sql_uai_name" {
  type        = string
  description = "Name of the User Assigned Identity for SQL Server"
}

# sqlServer
variable "kv_id" {
  type        = string
  description = "Name of the Key Vault in which the admin credentials are put"
}

variable "private_endpoint_properties" {
  description = "Consolidated properties for the Function App Private Endpoint."
  type = object({
    private_dns_zone_ids_sql             = optional(list(string), [])
    private_endpoint_enabled             = optional(bool, false)
    private_endpoint_subnet_id           = optional(string, "")
    private_endpoint_resource_group_name = optional(string, "")
    private_service_connection_is_manual = optional(bool, false)
  })

  validation {
    condition = (
      can(var.private_endpoint_properties == null) ||
      can(var.private_endpoint_properties.private_endpoint_enabled == false) ||
      can((length(var.private_endpoint_properties.private_dns_zone_ids_sql) > 0 &&
        length(var.private_endpoint_properties.private_endpoint_subnet_id) > 0
        )
      )
    )
    error_message = "Both private_dns_zone_ids and private_endpoint_subnet_id must be provided if private_endpoint_enabled is true."
  }
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Specifies whether or not public network access is allowed for this server."
  default     = false
}

variable "sql_admin_object_id" {
  type        = string
  description = "The object ID from EntraID for SQL Server Admin."
}

variable "sqlversion" {
  type        = string #checkType
  description = "Version of SQL to be created"
  default     = "12.0"
}

variable "tlsver" {
  type        = number
  description = " The Minimum TLS Version for all SQL Database and SQL Data Warehouse databases associated with the server"
  default     = 1.2
}

/* --------------------------------------------------------------------------------------------------
  Database Variables
-------------------------------------------------------------------------------------------------- */
variable "collation" {
  type        = string
  description = "Specifies the collation of the database. Changing this forces a new resource to be created."
  default     = "SQL_Latin1_General_CP1_CI_AS"
}

variable "db_name_suffix" {
  type        = string
  description = "The name of the MS SQL Database. Changing this forces a new resource to be created."
  default     = "baseline"
}

variable "licence_type" {
  type        = string
  description = " Specifies the license type applied to this database. Possible values are LicenseIncluded and BasePrice"
  default     = "LicenseIncluded"
}

variable "long_term_retention_policy" {
  description = "The long term retention policy for the database"
  type = object({
    weekly_retention  = optional(string, null)
    monthly_retention = optional(string, null)
    yearly_retention  = optional(string, null)
    week_of_year      = optional(number, null)
  })
  default = {}
}

variable "max_gb" {
  type        = number
  description = "The max size of the database in gigabytes"
  default     = 5
}

variable "read_scale" {
  type        = bool
  description = "If enabled, connections that have application intent set to readonly in their connection string may be routed to a readonly secondary replica. This property is only settable for Premium and Business Critical databases."
  default     = false
}

variable "short_term_retention_policy" {
  type        = number
  description = "The short term retention policy for the database (in days)"
  default     = null
}

variable "storage_account_type" {
  type        = string
  description = "storage account type: Geo, GeoZone, Local and Zone"
  default     = "Local"
}

variable "sku" {
  type        = string #checkType
  description = "Specifies the name of the SKU used by the database. For example, GP_S_Gen5_2,HS_Gen4_1,BC_Gen5_2, ElasticPool, Basic,S0, P2 ,DW100c, DS100. Changing this from the HyperScale service tier to another service tier will create a new resource."
  default     = "50"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags to be applied throughout the deployment."
  default     = {}
}

variable "zone_redundant" {
  type        = bool
  description = "To disable zone redundancy."
  default     = false
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "id of the log analytics workspace to send resource logging to via diagnostic settings"
}

variable "log_monitoring_enabled" {
  type        = bool
  description = "Default value for Log Monitoring Enabled"
  default     = true
}

/* --------------------------------------------------------------------------------------------------
  Auditing and Diagnostics Variables - Database
-------------------------------------------------------------------------------------------------- */

variable "database_extended_auditing_policy_enabled" {
  type        = bool
  description = "Enable extended auditing policy for SQL database"
  default     = true
}

variable "primary_blob_endpoint_name" {
  type        = string
  description = "Name of storage account primary endpoint"
}

variable "monitor_diagnostic_setting_database_enabled_logs" {
  type        = list(string)
  description = "Controls what logs will be enabled for the database"
}

variable "monitor_diagnostic_setting_database_metrics" {
  type        = list(string)
  description = "Controls what metrics will be enabled for the database"
}

/* --------------------------------------------------------------------------------------------------
  Auditing and Diagnostics Variables - Server
-------------------------------------------------------------------------------------------------- */

variable "auditing_policy_retention_in_days" {
  type        = number
  description = "number of days for audit log policies"
  default     = 6
}

variable "monitor_diagnostic_setting_sql_server_enabled_logs" {
  type        = list(string)
  description = "Controls what logs will be enabled for the sql server"
}

variable "monitor_diagnostic_setting_sql_server_metrics" {
  type        = list(string)
  description = "Controls what metrics will be enabled for the sql server"
}

variable "security_alert_policy_retention_days" {
  type        = number
  description = "number of days for security alert log policies"
  default     = 6
}

variable "sql_server_alert_policy_state" {
  type        = string
  description = "Controls the sql server alert policy state"
}

variable "storage_account_id" {
  type        = string
  description = "Id of the storage account to send audit logging to"
}

variable "storage_account_name" {
  type        = string
  description = "Name of the storage account to send audit logging to (unused)"
}

variable "storage_container_id" {
  type        = string
  description = "Storage container id to save audit data to"
}

variable "vulnerability_assessment_enabled" {
  type        = bool
  description = "to enable extended auditing policy for server or database"
  default     = false
}
