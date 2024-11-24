variable "autoscale_max" {
  type    = number
  default = null
}

variable "autoscale_min" {
  type    = number
  default = null
}

variable "backend_address_pool" {
  description = "A map of backend address pools with either 'ip_addresses' or 'fqdns' for each target. The key name will be used to retrieve the name from var.names."
  type        = map(object({
    ip_addresses = optional(list(string))
    fqdns        = optional(list(string))
  }))
}

variable "backend_http_settings" {
  description = "A map of backend HTTP settings for the Application Gateway. The key name will be used to retrieve the name from var.names."
  type        = map(object({
    cookie_based_affinity                 = string
    affinity_cookie_name                  = optional(string)
    path                                  = optional(string)
    port                                  = number
    probe_key                             = optional(string) # Since the names map is only interpolated inside the module, we have to pass in the probe key from the root module
    protocol                              = string
    request_timeout                       = optional(number)
    host_name                             = optional(string)
    pick_host_name_from_backend_address   = optional(bool)
    trusted_root_certificate_names        = optional(list(string))
    connection_draining                   = optional(object({
      enabled           = bool
      drain_timeout_sec = number
    }))
  }))
}

variable "frontend_port" {
  description = "A map of front end port numbers. The key name will be used to retrieve the name from var.names."
  type        = map(object({
    port = number
  }))
}

variable "frontend_ip_configuration" {
  description = "A map of frontend IP configurations, each with either a public IP or private IP configuration. The key name will be used to retrieve the name from var.names."
  type        = map(object({
    public_ip_address_id          = optional(string)
    subnet_id                     = optional(string)
    private_ip_address            = optional(string)
    private_ip_address_allocation = optional(string)
  }))
}

variable "gateway_subnet" {
  description = "The entire gateway subnet module object."
  type        = any
}

variable "key_vault_id" {
  type        = string
}

variable "location" {
  type        = string
  description = "location"
}

variable "probe" {
  description = "A map of health probes for the Application Gateway. The key name will be used to retrieve the name from var.names."
  type        = map(object({
    host                                      = string
    interval                                  = number
    path                                      = string
    pick_host_name_from_backend_http_settings = bool
    protocol                                  = string
    timeout                                   = number
    unhealthy_threshold                       = number
    minimum_servers                           = optional(number)
    port                                      = optional(number)
    match                                     = optional(object({
      status_code = list(number)
      body        = optional(string)
    }))
  }))
}

variable "min_tls_ver" {
  description = "Minimum allowed version of TLS"
  default     = "TLSv1_2"
}

variable "names" {
  description = "A map containing configuration object names for the Application Gateway."
  type        = any
}

variable "public_ip_address_id" {
  type = string
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Application Gateway. Changing this forces a new resource to be created."
}

variable "sku" {
  type        = string
  description = "The SKU of the Application Gateway (Basic, Standard_v2, or WAF_v2)."  
}

variable "ssl_certificate" {
  description = "A map of SSL certificates. Each entry can contain either 'data' (with optional pfx 'password'), or 'key_vault_secret_id'. The key name will be used to retrieve the name from var.names."
  type        = map(object({
    data                = optional(string)
    key_vault_secret_id = optional(string)
    password            = optional(string)
  }))
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
