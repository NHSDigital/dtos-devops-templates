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

variable "ftps_state" {
  type        = string
  description = "Enable FTPS enforcement for enhanced security. Allowed values = AllAllowed (i.e. FTP & FTPS), FtpsOnly and Disabled (i.e. no FTP/FTPS access). Defaults to AllAllowed."
  default     = "Disabled"

  validation {
    condition     = contains(["AllAllowed", "FtpsOnly", "Disabled"], var.ftps_state)
    error_message = "ftps_state must be one of AllAllowed, FtpsOnly or Disabled."
  }
}

variable "https_only" {
  type        = bool
  description = "Can the Function App only be accessed via HTTPS? Defaults to false."
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

variable "sa_name" {
  type        = string
  description = "The name of the Storage Account."
}

variable "sa_prm_key" {
  type        = string
  description = "The Storage Account Primary Access Key."
}

variable "tags" {
  type        = map(string)
  description = "Resource tags to be applied throughout the deployment."
  default     = {}
}

variable "worker_32bit" {
  type        = bool
  description = "Should the Windows Function App use a 32-bit worker process. Defaults to true"
}
