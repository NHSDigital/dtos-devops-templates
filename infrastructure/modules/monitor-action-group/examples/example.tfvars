regions = {
  uksouth = {
    is_primary_region = true
    address_space     = "10.113.0.0/16"
    connect_peering   = false
    subnets           = {}
  }
}

monitor_action_group = {

  action_group_1 = {
    short_name = "group1"
    email_receiver = {
      alert_team = {
        name                    = "email1"
        email_address           = "alert_team@testing.com"
        use_common_alert_schema = false
      }

      devops = {
        name                    = "email2"
        email_address           = "devops@testing.com"
        use_common_alert_schema = false
      }
    }
  }

  action_group_2 = {
    short_name = "group2"
    webhook_receiver = {
      slack_alerts = {
        name                    = "slack_alerts"
        service_uri             = "http://example.com/alert1"
        use_common_alert_schema = false
      }
      monitoring_alerts = {
        name                    = "webhook2"
        service_uri             = "http://example.com/slack"
        use_common_alert_schema = false
      }
    }
  }

  action_group_3 = {
    short_name = "group3"
    voice_receiver = {
      alerts1 = {
        name         = "voice_alerts"
        country_code = "44"
        phone_number = "1234567890"
      }
    }

    sms_receiver = {
      alerts2 = {
        name         = "sms_alerts"
        country_code = "44"
        phone_number = "1234567890"
      }
    }
  }

}

