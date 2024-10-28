variable "function_app_name" {
  description = "Name of the Function App"
}

variable "location" {
  type        = string
  description = "The location/region where the Function App is created."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Function App. Changing this forces a new resource to be created."
}

variable "ai_connstring" {
  type        = string
  description = "The App Insights connection string."
}

variable "acr_login_server" {
  type        = string
  description = "The login server for the Azure Container Registry."
}

variable "acr_mi_client_id" {
  description = "The Managed Identity Id for the Azure Container Registry."
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
  description = "The list of User Assigned Identity IDs to assign to the Function App."
}

variable "cont_registry_use_mi" {
  description = "Should connections for Azure Container Registry use Managed Identity."
}

variable "cors_allowed_origins" {
  type    = list(string)
  default = [""]
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

variable "http_version" {
  type        = string
  description = "The HTTP version to use for the function app. Override standard default."
  default     = "2.0"

  validation {
    condition     = contains(["1.1", "2.0"], var.http_version)
    error_message = "https_version must be one of 1.1 or 2.0."
  }
}

variable "https_only" {
  type        = bool
  description = "Can the Function App only be accessed via HTTPS? Override standard default."
  default     = true
}

variable "image_name" {
  description = "Name of the docker image"
}

variable "image_tag" {
  description = "Tag of the docker image"
}

variable "minimum_tls_version" {
  type    = string
  default = "1.2" # Possible versions: TLS1.0", "TLS1.1", "TLS1.2

  validation {
    condition     = contains(["1.0", "1.1", "1.2"], var.minimum_tls_version)
    error_message = "Minimum_tls_version must be one of 1.0, 1.1 or 1.2."
  }
}

variable "remote_debugging_enabled" {
  type    = string
  default = "false"
}

variable "private_endpoint_properties" {
  description = "Consolidated properties for the Function App Private Endpoint."
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

variable "public_network_access_enabled" {
  type        = bool
  description = "Should the Function App be accessible from the public network. Override standard default."
  default     = false
}

variable "rbac_role_assignments" {
  description = "Map of RBAC role assignments by region"
  type = list(object({
    role_definition_name = string
    scope                = string
  }))
}

variable "storage_account_name" {
  type        = string
  description = "The name of the Storage Account."
}

variable "storage_account_access_key" {
  type        = string
  description = "The Storage Account Primary Access Key."
}

variable "storage_uses_managed_identity" {
  type        = bool
  description = "Should the Storage Account use a Managed Identity. Defaults to false."
  default     = false
}

variable "vnet_integration_subnet_id" {
  type        = string
  description = "The ID of the subnet to integrate the Function App with."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Resource tags to be applied throughout the deployment."
  default     = {}
}

variable "webdeploy_publish_basic_authentication_enabled" {
  type        = bool
  description = "Enable basic authentication for WebDeploy. Override standard default."
  default     = false
}

variable "worker_32bit" {
  type        = bool
  description = "Should the Windows Function App use a 32-bit worker process. Defaults to true"
}
