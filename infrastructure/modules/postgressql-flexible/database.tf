
resource "azurerm_postgresql_flexible_server_database" "postgresql_flexible_db" {
  for_each = var.databases

  name      = each.value.name
  server_id = azurerm_postgresql_flexible_server.postgresql_flexible_server.id
  charset   = each.value.charset
  collation = each.value.collation
}
