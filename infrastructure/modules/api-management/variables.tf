variable "name" {
  description = "The name of the API Management service."
  type        = string
  validation {
    condition     = length(var.name) <= 50
    error_message = "The API Management service name must be less than or equal to 50 characters."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which the API Management service should be created."
  type        = string
}

variable "location" {
  description = "The location/region where the API Management service should be created."
  type        = string
  validation {
    condition     = contains(["uksouth", "ukwest"], var.location)
    error_message = "The location must be either uksouth or ukwest."
  }
}

variable "additional_locations" {
  description = "A list of additional locations where the API Management service should be created."
  type = list(object({
    location             = string
    capacity             = number
    zones                = list(number)
    public_ip_address_id = string
    virtual_network_configuration = list(object({
      subnet_id = string
    }))
  }))
  default = []
}

variable "certificate_details" {
  description = "A list of certificates to upload to the API Management service."
  type = list(object({
    encoded_certificate  = string
    store_name           = string
    certificate_password = string
  }))
  default = []
}

variable "developer_portal_hostname_configuration" {
  description = "Developer Portal hostname configurations."
  type = list(object({
    host_name                    = string
    key_vault_id                 = optional(string)
    certificate                  = optional(string)
    certificate_password         = optional(string)
    negotiate_client_certificate = optional(bool, false)
  }))
  default  = []
  nullable = false
}

variable "gateway_disabled" {
  description = "Specifies whether the gateway is disabled."
  type        = bool
  default     = false
  validation {
    condition     = var.gateway_disabled == false || length(var.additional_locations) > 0
    error_message = "The gateway can only be disabled when additional locations are provided."
  }
}

variable "identity_ids" {
  description = "The identity IDs for the API Management service."
  type        = list(string)
  default     = []
}

variable "identity_type" {
  description = "The type of identity for the API Management service."
  type        = string
  validation {
    condition     = contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "The identity type must be either SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned."
  }
  default = "SystemAssigned"
}

variable "management_hostname_configuration" {
  description = "List of management hostname configurations."
  type = list(object({
    host_name                    = string
    key_vault_id                 = optional(string)
    certificate                  = optional(string)
    certificate_password         = optional(string)
    negotiate_client_certificate = optional(bool, false)
  }))
  default  = []
  nullable = false
}

variable "proxy_hostname_configuration" {
  description = "List of proxy hostname configurations."
  type = list(object({
    host_name                    = string
    default_ssl_binding          = optional(bool, false)
    key_vault_id                 = optional(string)
    certificate                  = optional(string)
    certificate_password         = optional(string)
    negotiate_client_certificate = optional(bool, false)
  }))
  default  = []
  nullable = false
}

variable "public_ip_address_id" {
  description = "The ID of the public IP address to associate with the API Management service."
  type        = string
  default     = null
}

variable "publisher_email" {
  description = "The email address of the publisher of the API Management service."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.publisher_email))
    error_message = "The publisher email address is not valid."
  }
}

variable "publisher_name" {
  description = "The name of the publisher of the API Management service."
  type        = string
}

variable "scm_hostname_configuration" {
  description = "List of SCM hostname configurations."
  type = list(object({
    host_name                    = string
    key_vault_id                 = optional(string)
    certificate                  = optional(string)
    certificate_password         = optional(string)
    negotiate_client_certificate = optional(bool, false)
  }))
  default  = []
  nullable = false
}

variable "sku_capacity" {
  description = "The capacity of the SKU of the API Management service."
  type        = number
  validation {
    condition     = var.sku_capacity > 0 && var.sku_capacity < 10
    error_message = "The SKU capacity must be a positive integer less than 10."
  }
}

variable "sku_name" {
  description = "The name of the SKU of the API Management service."
  type        = string
  validation {
    condition     = contains(["Consumption", "Developer", "Basic", "Standard", "Premium"], var.sku_name)
    error_message = "The SKU name must be either Consumption, Developer, Basic, Standard, or Premium."
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the API Management service."
  type        = map(string)
  default     = {}
}

variable "virtual_network_configuration" {
  description = "The virtual network configuration for the API Management service."
  type        = list(string)
  default     = null
  validation {
    condition     = var.virtual_network_type == "Internal" && length(var.virtual_network_configuration) > 0
    error_message = "The virtual network configuration must be provided when the virtual network type is Internal."
  }
}

variable "virtual_network_type" {
  description = "The type of virtual network configuration for the API Management service."
  type        = string
  validation {
    condition     = contains(["None", "External", "Internal"], var.virtual_network_type)
    error_message = "The virtual network type must be either None, External or Internal."
  }
  default = "Internal"
}

variable "zones" {
  description = "A list of availability zones where the API Management service should be created."
  type        = list(number)
  default     = []
  validation {
    condition     = length(var.zones) <= 3
    error_message = "The number of availability zones must be less than or equal to 3."
  }
}


/*_________________________________________________
  API Management AAD Identity Provider variables.
_________________________________________________*/

variable "allowed_tenants" {
  description = "A list of allowed tenants for the API Management AAD Identity Provider."
  type        = list(string)
  default     = []
}

variable "client_id" {
  description = "The client ID for the API Management AAD Identity Provider."
  type        = string
}

variable "client_library" {
  description = "The client library for the API Management AAD Identity Provider."
  type        = string
  default     = "MSAL"
}

variable "client_secret" {
  description = "The client secret for the API Management AAD Identity Provider."
  type        = string
}
