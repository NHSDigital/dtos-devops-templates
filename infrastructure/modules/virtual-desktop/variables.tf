variable "custom_rdp_properties" {
  type    = string
  default = null
}

variable "dag_default_desktop_display_name" {
  type    = string
  default = "SessionDesktop"
}

variable "dag_description" {
  type    = string
  default = null
}

variable "dag_friendly_name" {
  type    = string
  default = null
}

variable "dag_name" {
  description = "The name of the AVD Desktop Application Group (DAG)"
  type        = string
}

variable "dag_type" {
  type    = string
  default = "Desktop"
}

variable "host_pool_description" {
  type    = string
  default = null
}

variable "host_pool_friendly_name" {
  type    = string
  default = null
}

variable "host_pool_name" {
  description = "The name of the AVD host pool"
  type        = string
}

variable "host_pool_type" {
  type    = string
  default = "Pooled"
}

variable "load_balancer_type" {
  type    = string
  default = "BreadthFirst" #"DepthFirst"
}

variable "location" {
  type = string
}

variable "login_principal_id" {
  type        = string
  description = "The ids of the groups to grant AVD acccess to, specified via TF_VAR env var."
}

variable "maximum_sessions_allowed" {
  type    = number
  default = 16
}

variable "source_image_offer" {
  type = string
}

variable "source_image_publisher" {
  type = string
}

variable "source_image_sku" {
  type = string
}

variable "source_image_version" {
  type = string
}

variable "subnet_id" {
  type        = string
  description = "The subnet id which will contain the AVD session host."
}

variable "validate_environment" {
  type        = bool
  description = "Validation host pool allows you to test service changes before they are deployed to production."
  default     = false
}

variable "vm_count" {
  type    = number
  default = 1
}

variable "vm_disk_size" {
  type        = number
  description = "The OS disk size in GB."
  default     = 128
}

variable "vm_license_type" {
  type = string
}

variable "vm_name_prefix" {
  type = string
}

variable "vm_size" {
  type    = string
  default = "Standard_D2as_v5"
}

variable "vm_storage_account_type" {
  type    = string
  default = "StandardSSD_LRS"
}

variable "workspace_description" {
  type    = string
  default = null
}

variable "workspace_friendly_name" {
  type    = string
  default = null
}

variable "workspace_name" {
  description = "The name of the AVD workspace"
  type        = string
}

variable "resource_group_id" {
  description = "The id of the resource group in which to create the Azure Virtual Desktop."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Azure Virtual Desktop."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
