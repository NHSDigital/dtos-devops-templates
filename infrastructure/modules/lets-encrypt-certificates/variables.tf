variable "certificates" {
  description = "Map of certificates names with their subject names (DNS names)."
  type        = map(string)
}

variable "dns_zone_names" {
  type        = map(string)
  description = "Map of zone identifiers to their full private DNS zone names"
}

variable "dns_zone_resource_group_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "email" {
  description = "Contact email address for certificate expiry notifications."
  type        = string
}

variable "key_vaults" {
  description = "Key Vaults to store the certificates in."
  type        = map(any)
}

variable "storage_account_name_hub" {
  type = string
}

variable "subscription_id_hub" {
  type = string
}

variable "subscription_id_target" {
  type = string
}
