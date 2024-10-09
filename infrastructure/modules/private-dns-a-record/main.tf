
resource "azurerm_private_dns_a_record" "a_record" {

  name                = var.name
  zone_name           = var.private_dns_a_record.zone_name
  resource_group_name = var.resource_group_name
  ttl                 = var.private_dns_a_record.a_record_ttl
  records             = var.private_dns_a_record.ip_address

  tags = var.tags
}
