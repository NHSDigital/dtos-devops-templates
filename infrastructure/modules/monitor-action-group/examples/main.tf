module "monitor_action_group" {
  for_each = local.monitor_action_group_map

  source = "../monitor-action-group"

  name                = "${module.regions_config[each.value.region].names.monitor-action-group}-${lower(each.value.short_name)}"
  resource_group_name = azurerm_resource_group.core[each.value.region].name
  location            = each.value.region
  short_name          = each.value.short_name
  email_receiver      = each.value.email_receiver
  event_hub_receiver  = each.value.event_hub_receiver
  sms_receiver        = each.value.sms_receiver
  voice_receiver      = each.value.voice_receiver
  webhook_receiver    = each.value.webhook_receiver
}

locals {
  monitor_action_group_object_list = flatten([
    for region in keys(var.regions) : [
      for action_group_key, action_group_details in var.monitor_action_group : merge(
        {
          region           = region
          action_group_key = action_group_key
        },
        action_group_details
      )
    ]
  ])

  # ...then project the list of objects into a map with unique keys (combining the iterators), for consumption by a for_each meta argument
  monitor_action_group_map = {
    for object in local.monitor_action_group_object_list : "${object.action_group_key}-${object.region}" => object
  }
}

