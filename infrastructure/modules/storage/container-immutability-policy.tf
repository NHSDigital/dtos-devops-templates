resource "azurerm_storage_container_immutability_policy" "policy" {

  for_each = { for k, v in var.containers : k => v.immutability_policy if v.immutability_policy != null }

  storage_container_resource_manager_id = azurerm_storage_container.container[each.key].resource_manager_id

  immutability_period_in_days         = each.value.immutability_period_in_days
  protected_append_writes_all_enabled = each.value.protected_append_writes_all_enabled
  protected_append_writes_enabled     = each.value.protected_append_writes_enabled

  # Caution: Once locked, the container cannot be unlocked or otherwise modified: See ./README.md
  locked = each.value.is_locked

  depends_on = [azurerm_storage_container.container]
}
