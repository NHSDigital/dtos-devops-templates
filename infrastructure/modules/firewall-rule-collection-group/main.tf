resource "azurerm_firewall_policy_rule_collection_group" "policy_rule_collection_group" {
  name               = var.name
  firewall_policy_id = var.firewall_policy_id
  priority           = var.priority

  # create a dynamic application_rule_collection block that allow none or many
  dynamic "application_rule_collection" {
    for_each = var.application_rule_collection
    content {
      name     = application_rule_collection.value.name
      priority = application_rule_collection.value.priority
      action   = application_rule_collection.value.action

      rule {
        name = application_rule_collection.value.rule_name
        dynamic "protocols" {
          for_each = application_rule_collection.value.protocols
          content {
            type = protocols.value.type
            port = protocols.value.port
          }
        }
        source_addresses  = application_rule_collection.value.source_addresses
        destination_fqdns = application_rule_collection.value.destination_fqdns

      }
    }
  }
  dynamic "network_rule_collection" {
    for_each = var.network_rule_collection
    content {
      name     = network_rule_collection.value.name
      priority = network_rule_collection.value.priority
      action   = network_rule_collection.value.action

      rule {
        name                  = network_rule_collection.value.rule_name
        protocols             = network_rule_collection.value.protocols
        source_addresses      = network_rule_collection.value.source_addresses
        destination_addresses = network_rule_collection.value.destination_addresses
        destination_ports     = network_rule_collection.value.destination_ports
      }
    }

  }
  dynamic "nat_rule_collection" {
    for_each = var.nat_rule_collection
    content {
      name     = nat_rule_collection.value.name
      priority = nat_rule_collection.value.priority
      action   = nat_rule_collection.value.action

      rule {
        name                = nat_rule_collection.value.rule_name
        protocols           = nat_rule_collection.value.protocols
        source_addresses    = nat_rule_collection.value.source_addresses
        destination_address = nat_rule_collection.value.destination_address
        destination_ports   = nat_rule_collection.value.destination_ports
        translated_address  = nat_rule_collection.value.translated_address
        translated_port     = nat_rule_collection.value.translated_port
      }
    }
  }
}
