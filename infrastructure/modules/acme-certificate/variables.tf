variable "acme_registration_account_key_pem" {
  description = "Account key for the ACME registration, created once in the root module."
  type        = string
}

variable "certificate" {
  # https://registry.terraform.io/providers/vancluever/acme/latest/docs/resources/certificate
  description = "Details of ACME certificate to be requested."
  type = object({
    common_name                 = string
    subject_alternative_names   = optional(list(string))
    dns_cname_zone_name         = optional(string) # CNAME for redirecting DNS-01 challenges
    dns_private_cname_zone_name = optional(string) # CNAME for redirecting DNS-01 challenges
    dns_challenge_zone_name     = string
    dns_challenge_zone_rg_name  = optional(string)         # Allows override per certificate if needed
    key_type                    = optional(string, "P256") # Follow certbot default of ECDSA P256
  })
}

variable "certificate_name" {
  type = string
}

variable "key_vaults" {
  description = "Key Vaults to store the certificates in, keyed by region."
  type        = map(any)
}

variable "private_dns_zones" {
  description = "Private DNS Zones, keyed by region, to determine local resource group name. Optionally used to satisfy Lego azuredns checks for CNAME redirections of DNS-01 challenges."
  type        = map(any)
  default     = null
}

variable "public_dns_zone_resource_group_name" {
  type = string
}

variable "subscription_id_dns_public" {
  type = string
}
