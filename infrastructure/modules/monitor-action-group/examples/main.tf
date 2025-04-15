module "monitor_action_group" {
  source = "./modules/monitor-action-group"

  name                = "example-monitor-action-group"
  resource_group_name = azurerm_resource_group.core[each.key].name
  location            = each.key
  short_name          = "testing123"

  email_receiver = [
    {
      name                    = "testing"
      email_address           = "testing@testing.com"
      use_common_alert_schema = false
    }
  ]
}
