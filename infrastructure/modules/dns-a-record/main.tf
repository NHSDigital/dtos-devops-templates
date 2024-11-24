resource "azurerm_dns_a_record" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  records             = var.records
  target_resource_id  = var.target_resource_id
  ttl                 = var.ttl
  zone_name           = var.zone_name

  tags = var.tags
}
