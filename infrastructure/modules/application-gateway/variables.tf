variable "application_gateway_autoscale_max" {
  type    = number
  default = 100
}

variable "application_gateway_autoscale_min" {
  type    = number
  default = 10
}

variable "common_names" {
  type = map(any)
}

variable "gateway_subnet" {
  type = map(any)
}

variable "location" {
  type        = string
  description = "location"
}

variable "min_tls_ver" {
  description = "Minimum allowed version of TLS"
  default     = "TLSv1_3"
}

variable "name" {
  type        = string
  description = "The name of the Application Gateway."
}

variable "public_ip_address_id" {
  type = string
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Application Gateway. Changing this forces a new resource to be created."
}

variable "tags" {
  type        = map(string)
  description = "Resource tags to be applied throughout the deployment."
  default     = {}
}
