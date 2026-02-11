variable "name" {
  description = "The name of the Storage Account."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "The Azure Storage Account name must be between 3 and 24 characters and can only contain lowercase letters and numbers."
  }

  validation {
    condition     = length(var.name) <= 24
    error_message = "The Storage Account name must be between 3 and 24 characters in length."
  }
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Storage Account. Changing this forces a new resource to be created."
}

variable "location" {
  type        = string
  description = "The location/region where the Storage Account is created."
}

variable "account_replication_type" {
  type        = string
  description = "The type of replication to use for this Storage Account. Can be either LRS, GRS, RAGRS or ZRS."
  default     = "LRS"

}

variable "account_tier" {
  type        = string
  description = "Defines the Tier to use for this storage account. Valid options are Standard and Premium."
  default     = "Standard"
}

variable "access_tier" {
  type        = string
  description = "Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are Hot, Cool, Cold and Premium."
  default     = "Hot"
}

variable "blob_properties_delete_retention_policy" {
  type        = number
  description = "The value set for blob properties delete retention policy."
  default     = null
}

variable "blob_properties_versioning_enabled" {
  type        = bool
  description = "To enable versioning for blob."
  default     = false
}

variable "containers" {
  description = "Definition of Storage Containers configuration, including optional immutability policy settings."
  type = map(object({
    container_name        = string
    container_access_type = string
    immutability_policy = optional(object({
      is_locked                           = optional(bool, false)
      immutability_period_in_days         = optional(number, 0)
      protected_append_writes_all_enabled = optional(bool, false)
      protected_append_writes_enabled     = optional(bool, false)
    }))
  }))
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Id of the log analytics workspace to send resource logging to via diagnostic settings"
}

variable "monitor_diagnostic_setting_storage_account_enabled_logs" {
  type        = list(string)
  description = "Controls what logs will be enabled for the storage services"
}

variable "monitor_diagnostic_setting_storage_account_metrics" {
  type        = list(string)
  description = "Controls what metrics will be enabled for the storage services"
}

variable "monitor_diagnostic_setting_storage_account_resource_metrics" {
  type        = list(string)
  description = "Controls what metrics will be enabled for the storage account itself"
  default     = ["Transaction"]
}

variable "private_endpoint_properties" {
  description = "Consolidated properties for the Function App Private Endpoint."
  type = object({
    private_dns_zone_ids_blob            = optional(list(string), [])
    private_dns_zone_ids_table           = optional(list(string), [])
    private_dns_zone_ids_queue           = optional(list(string), [])
    private_endpoint_enabled             = optional(bool, false)
    private_endpoint_subnet_id           = optional(string, "")
    private_endpoint_resource_group_name = optional(string, "")
    private_service_connection_is_manual = optional(bool, false)
  })

  validation {
    condition = (
      can(var.private_endpoint_properties == null) ||
      can(var.private_endpoint_properties.private_endpoint_enabled == false) ||
      can((length(var.private_endpoint_properties.private_dns_zone_ids_blob) > 0 &&
        length(var.private_endpoint_properties.private_dns_zone_ids_queue) > 0 &&
        length(var.private_endpoint_properties.private_endpoint_subnet_id) > 0
        )
      )
    )
    error_message = "Both private_dns_zone_ids and private_endpoint_subnet_id must be provided if private_endpoint_enabled is true."
  }
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Controls whether data in the account may be accessed from public networks."
  default     = false
}

variable "queues" {
  description = "List of Storage Queues to create."
  type        = list(string)
  default     = []
}

variable "rbac_roles" {
  description = "List of RBAC roles to assign to the Storage Account."
  type        = list(string)
  default     = []
}

variable "storage_account_service" {
  type    = set(string)
  default = ["blobServices", "queueServices", "tableServices", "fileServices"]
}

variable "tags" {
  type        = map(string)
  description = "Resource tags to be applied throughout the deployment."
  default     = {}
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

variable "enable_alerting" {
  description = "Whether monitoring and alerting is enabled for the PostgreSQL Flexible Server."
  type        = bool
  default     = false
}

variable "action_group_id" {
  type        = string
  description = "ID of the action group to notify."
  default     = null
}

variable "availability_low_threshold" {
  type        = number
  description = "This will alert of storage queue transactions is higher that given value, default will be 99."
  default     = 99
}

variable "success_e2e_latency_threshold" {
  type        = number
  description = "This will alert if the E2E success latency is higher that given value (in milliseconds), default will be 500."
  default     = 500
}

variable "queue_transactions_high_threshold" {
  type        = number
  description = "This will alert of storage queue transactions is higher that given value, default will be 1000."
  default     = 1000
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
