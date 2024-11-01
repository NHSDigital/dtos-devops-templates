variable "autoscale_max" {
  type    = number
  default = null
}

variable "autoscale_min" {
  type    = number
  default = null
}

variable "common_names" {
  description = "A map containing configuration object names for the Application Gateway."
  type        = any
}

variable "gateway_subnet" {
  description = "The entire gateway subnet module object."
  type        = any
}

variable "location" {
  type        = string
  description = "location"
}

variable "min_tls_ver" {
  description = "Minimum allowed version of TLS"
  default     = "TLSv1_3"
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

variable "zones" {
  description = "The availability zones which the Application Gateway will span."
  type        = list(string)
}
