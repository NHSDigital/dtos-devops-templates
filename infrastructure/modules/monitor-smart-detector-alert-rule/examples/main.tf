module "azurerm_monitor_smart_detector_alert_rule" {
  for_each = local.monitor_action_group_map

  source = "../../dtos-devops-templates/infrastructure/modules/monitor-smart-detector-alert-rule"

  name                = "ServiceHealth-Incidents-${each.value.name_suffix}"
  resource_group_name = azurerm_resource_group.rg_base[each.value.region].name
  subscription_id     = var.TARGET_SUBSCRIPTION_ID
  action_group_id     = module.monitor_action_group[each.key].monitor_action_group.id
  scope_resource_ids  = [each.value.app_insights_id]

  detector_type = "FailureAnomaliesDetector"
  description   = "FailureAnomaliesDetector"

}

data "azurerm_resources" "all_app_insights" {
  type = "microsoft.insights/components"
}

locals {
  app_insights_ids_in_subscription = [
    for r in data.azurerm_resources.all_app_insights.resources : r.id
    if lower(split("/", r.id)[2]) == lower(var.TARGET_SUBSCRIPTION_ID)
  ]
}

locals {

  monitor_action_group_object_list = flatten([
    for region in keys(var.regions) : [
      for id in local.app_insights_ids_in_subscription : [
        for action_group_key, action_group_details in var.monitor_action_group : merge(
          {
            short_name       = substr(var.TARGET_SUBSCRIPTION_ID, 0, 3)
            region           = region
            app_insights_id  = id
            name_suffix      = replace(element(split("/", id), length(split("/", id)) - 1), "_", "-")
            action_group_key = action_group_key
          },
          action_group_details,
        )
      ]
    ]
  ])

  monitor_action_group_map = {
    for object in local.monitor_action_group_object_list : "${object.action_group_key}-${object.region}-${object.app_insights_id}" => object
  }
}
