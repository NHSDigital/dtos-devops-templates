variable "acr_login_server" {
  type        = string
  description = "The login server for the Azure Container Registry."
}

variable "acr_mi_client_id" {
  description = "The Managed Identity Id for the Azure Container Registry."
}

variable "always_on" {
  type        = bool
  description = "Should the Web App be always on. Override standard default."
  default     = true
}

variable "app_settings" {
  description = "Map of values for the app settings"
  default     = {}
}

variable "asp_id" {
  type        = string
  description = "The ID of the AppServicePlan."
}

variable "assigned_identity_ids" {
  type        = list(string)
  description = "The list of User Assigned Identity IDs to assign to the Web App."
}

variable "cont_registry_use_mi" {
  description = "Should connections for Azure Container Registry use Managed Identity."
}

variable "cors_allowed_origins" {
  type    = list(string)
  default = []
}

variable "custom_domains" {
  type    = list(string)
  default = []
}

variable "docker_image_name" {
  type    = string
  default = ""
}

variable "entra_id_group_ids" {
  type    = list(string)
  default = []
}

variable "ftp_publish_basic_authentication_enabled" {
  type        = bool
  description = "Enable basic authentication for FTP. Defaults to false."
  default     = false
}

variable "ftps_state" {
  type        = string
  description = "Enable FTPS enforcement for enhanced security. Allowed values = AllAllowed (i.e. FTP & FTPS), FtpsOnly and Disabled (i.e. no FTP/FTPS access). Defaults to AllAllowed."
  default     = "Disabled"

  validation {
    condition     = contains(["AllAllowed", "FtpsOnly", "Disabled"], var.ftps_state)
    error_message = "ftps_state must be one of AllAllowed, FtpsOnly or Disabled."
  }
}

variable "health_check_path" {
  type        = string
  description = "The path to be checked for this linux web app health."
  default     = null
}

variable "health_check_eviction_time_in_min" {
  type        = number
  description = "The time in minutes a node can be unhealthy before being removed from the load balancer."
  default     = null
}

variable "ip_restriction_default_action" {
  description = "Default action for FW rules"
  type        = string
  default     = "Deny"
}

variable "ip_restrictions" {
  type = map(object({
    headers = optional(list(object({
      x_azure_fdid      = optional(list(string))
      x_fd_health_probe = optional(list(string))
      x_forwarded_for   = optional(list(string))
      x_forwarded_host  = optional(list(string))
    })), [])
    ip_address                = optional(string)
    name                      = optional(string)
    priority                  = optional(number)
    action                    = optional(string, "Deny")
    service_tag               = optional(string)
    virtual_network_subnet_id = optional(string)
  }))
  default = {}
}

variable "http_version" {
  type        = string
  description = "The HTTP version to use for the linux web app. Override standard default."
  default     = "2.0"

  validation {
    condition     = contains(["1.1", "2.0"], var.http_version)
    error_message = "https_version must be one of 1.1 or 2.0."
  }
}

variable "https_only" {
  type        = bool
  description = "Can the Web App only be accessed via HTTPS? Override standard default."
  default     = true
}

variable "linux_web_app_name" {
  description = "Name of the Web App"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{0,58}[a-zA-Z0-9]$", var.linux_web_app_name))
    error_message = "The Azure Linux Web App name must be between 1 and 60 characters, start with an alphanumeric character, end with an alphanumeric character, and can contain alphanumeric characters and hyphens."
  }
}

variable "linux_web_app_slots" {
  description = "linux web app slots"
  type = list(object({
    linux_web_app_slots_name    = optional(string, "")
    linux_web_app_slots_enabled = optional(bool, false)
  }))
  default = []
}

variable "location" {
  type        = string
  description = "The location/region where the Web App is created."
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "id of the log analytics workspace to send resource logging to via diagnostic settings"
}

variable "minimum_tls_version" {
  type    = string
  default = "1.2" # Possible versions: TLS1.0", "TLS1.1", "TLS1.2

  validation {
    condition     = contains(["1.0", "1.1", "1.2"], var.minimum_tls_version)
    error_message = "Minimum_tls_version must be one of 1.0, 1.1 or 1.2."
  }
}

variable "monitor_diagnostic_setting_linux_web_app_enabled_logs" {
  type        = list(string)
  description = "Controls what logs will be enabled for the linux web app"
}

variable "monitor_diagnostic_setting_linux_web_app_metrics" {
  type        = list(string)
  description = "Controls what metrics will be enabled for the linux web app"
}

variable "private_endpoint_properties" {
  description = "Consolidated properties for the Web App Private Endpoint."
  type = object({
    private_dns_zone_ids                 = optional(list(string), [])
    private_endpoint_enabled             = optional(bool, false)
    private_endpoint_subnet_id           = optional(string, "")
    private_endpoint_resource_group_name = optional(string, "")
    private_service_connection_is_manual = optional(bool, false)
  })

  validation {
    condition     = var.private_endpoint_properties.private_endpoint_enabled == false || (length(var.private_endpoint_properties.private_dns_zone_ids) > 0 && length(var.private_endpoint_properties.private_endpoint_subnet_id) > 0)
    error_message = "Both private_dns_zone_ids and private_endpoint_subnet_id must be provided if private_endpoint_enabled is true."
  }
}

variable "public_dns_zone_rg_name" {
  type        = string
  description = "Name of the Resource Group containing the public DNS zones in the Hub subscription."
  default     = null
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Should the Web App be accessible from the public network. Override standard default."
  default     = false
}

variable "rbac_role_assignments" {
  description = "Map of RBAC role assignments by region"
  type = list(object({
    role_definition_name = string
    scope                = string
  }))
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Web App. Changing this forces a new resource to be created."
}

variable "storage_account_access_key" {
  type        = string
  description = "The Storage Account Primary Access Key."
  default     = null
}

variable "storage_account_name" {
  type        = string
  description = "The name of the Storage Account."
  default     = null
}

variable "storage_name" {
  type        = string
  description = "The name of the Storage Account."
  default     = null
}

variable "share_name" {
  type        = string
  description = "The name which should be used for this Storage Account."
  default     = null
}

variable "storage_type" {
  type        = string
  description = "The Azure Storage Type. Possible values include AzureFiles and AzureBlob"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Resource tags to be applied throughout the deployment."
  default     = {}
}

variable "vnet_integration_subnet_id" {
  type        = string
  description = "The ID of the subnet to integrate the Web App with."
  default     = null
}

variable "webdeploy_publish_basic_authentication_enabled" {
  type        = bool
  description = "Enable basic authentication for WebDeploy. Override standard default."
  default     = false
}

variable "wildcard_ssl_cert_id" {
  type        = string
  description = "The ID of the wildcard SSL certificate associated to the App Service Plan, used for Custom Domain binding."
  default     = null
}

variable "worker_32bit" {
  type        = bool
  description = "Should the Windows Web App use a 32-bit worker process. Defaults to true"
}
