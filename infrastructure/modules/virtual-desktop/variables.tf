variable "custom_rdp_properties" {
  type    = string
  default = null
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
  default = "DepthFirst"  #"BreadthFirst"
}

variable "location" {
  description = "The location/region where the private endpoint will be created."
  type        = string
}

variable "login_principal_id" {
  type        = string
  description = "The ids of the groups to grant the 'Virtual Machine User Login' role to, specified via TF_VAR env var."
}

variable "maximum_sessions_allowed" {
  type    = number
  default = 16
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

variable "vm_size" {
  type        = string
  description = "The Virtual Machine SKU for the AVD session host."
  default     = "Standard_D2as_v5"
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
