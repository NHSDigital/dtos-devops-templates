/* --------------------------------------------------------------------------------------------------
  Azure Relay Hybrid Connection
-------------------------------------------------------------------------------------------------- */
resource "azurerm_relay_hybrid_connection" "hybrid_connection" {
  name                          = var.name
  relay_namespace_name          = var.relay_namespace_name
  resource_group_name           = var.resource_group_name
  requires_client_authorization = var.requires_client_authorization
  user_metadata                 = var.user_metadata
}

/* --------------------------------------------------------------------------------------------------
  Azure Relay Hybrid Connection Authorization Rules
-------------------------------------------------------------------------------------------------- */
resource "azurerm_relay_hybrid_connection_authorization_rule" "auth_rule" {
  for_each = var.authorization_rules

  name                   = each.key
  hybrid_connection_name = azurerm_relay_hybrid_connection.hybrid_connection.name
  namespace_name         = var.relay_namespace_name
  resource_group_name    = var.resource_group_name

  listen = each.value.listen
  send   = each.value.send
  manage = each.value.manage
}
