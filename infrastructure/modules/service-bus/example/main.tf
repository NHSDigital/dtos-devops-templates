module "azure_service_bus" {
  for_each = local.azure_service_bus_map

  source = "../../../dtos-devops-templates/infrastructure/modules/service-bus"

  servicebus_topic_map = each.value.topics
  # The namespace defaults to the object key unless a namespace is specified, then it overwrites it.
  servicebus_namespace_name = coalesce(each.value.namespace_name, each.key)
  resource_group_name       = azurerm_resource_group.core[each.value.region].name
  location                  = each.value.region
  capacity                  = each.value.capacity
  sku_tier                  = each.value.sku_tier

  tags = var.tags
}

locals {

  azure_service_bus_object_list = flatten([
    for region in keys(var.regions) : [
      for service_bus_key, service_bus_details in var.service_bus : merge(
        {
          region          = region
          service_bus_key = service_bus_key
        },
        service_bus_details
      )
    ]
  ])

  # ...then project the list of objects into a map with unique keys (combining the iterators), for consumption by a for_each meta argument
  azure_service_bus_map = {
    for object in local.azure_service_bus_object_list : "${object.service_bus_key}-${object.region}" => object
  }
}