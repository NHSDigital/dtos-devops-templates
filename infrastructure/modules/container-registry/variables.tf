
variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the ACR. Changing this forces a new resource to be created."
}

variable "name" {
  type        = string
  description = "The Azure Container Registry name."
}

variable "location" {
  type        = string
  description = "The location/region where the ACR is created."
}

variable "admin_enabled" {
  type        = string
  description = "Specifies whether the admin user is enabled."
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
  description = "Controls whether data in the account may be accessed from public networks."
  default     = false
}

variable "sku" {
  type        = string
  description = "The SKU of the ACR."
}

variable "uai_name" {
  type        = string
  description = "Name of the User Assigned Identity for ACR Push"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags to be applied throughout the deployment."
  default     = {}
}