regions = {
  uksouth = {
    is_primary_region = true
    address_space     = "10.113.0.0/16"
    connect_peering   = false
    subnets           = {}
  }
}

service_bus_subscriptions = {
  subscriber_config = {
    event-dev-ap = {
      subscription_name       = "events-sub"
      topic_name              = "events"
      namespace_name          = "dtoss-nsp"
      subscriber_functionName = "foundryRelay"
    }
  }
}

service_bus = {
  dtoss-nsp = {
    capacity         = 1
    sku_tier         = "Premium"
    max_payload_size = "100mb"
    topics = {
      events = {}
    }
  }
}
