variable "identity_ids" {
  description = "List of user-assigned identity IDs to associate with the profile. Required if identity_type includes UserAssigned"
  type        = list(string)
  default     = null
}

variable "identity_type" {
  description = "Identity type for the CDN Front Door Profile. Options: SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned"
  type        = string
  default     = null
}

variable "name" {
  description = "Name of the Azure CDN Front Door Profile"
  type        = string
}

variable "resource_group_name" {
  type = string
}

variable "response_timeout_seconds" {
  description = "Response timeout in seconds for the CDN Front Door Profile"
  type        = number
  default     = null
}

variable "sku_name" {
  description = "SKU name for the Azure CDN Front Door Profile (e.g., Standard_AzureFrontDoor or Premium_AzureFrontDoor)"
  type        = string
}
