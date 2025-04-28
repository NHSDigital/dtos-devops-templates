regions = {
  uksouth = {
    is_primary_region = true
    address_space     = "10.113.0.0/16"
    connect_peering   = false
    subnets           = {}
  }
}

service_bus = {
  dtoss-breast-screening = {
    capacity         = 1
    sku_tier         = "Premium"
    max_payload_size = "100mb"
    topics = {
      episode_uploaded  = {},
      episode_created   = {},
      episode_cancelled = {}
    }
  },
  dtoss-bowel-screening = {
    namespace_name   = "bowel-screening-for-all"
    capacity         = 1
    sku_tier         = "Premium"
    max_payload_size = "100mb"
    topics = {
      episode_uploaded  = {},
      episode_created   = {},
      episode_cancelled = {}
    }
  }
}

