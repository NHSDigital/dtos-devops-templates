# logic-app-slack-alert

Deploy an [Azure Logic App](https://learn.microsoft.com/en-us/azure/logic-apps/logic-apps-overview) that receives [Azure Monitor alert notifications](https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/action-groups) via HTTP and forwards them to a Slack channel as formatted messages.

## Terraform documentation

For the list of inputs, outputs, resources... check the [terraform module documentation](tfdocs.md).

## Prerequisites

- A Slack incoming webhook URL. Create one via **Slack App > Incoming Webhooks** and store it in Azure Key Vault. Pass the resolved secret value as `slack_webhook_url`.
- An [Azure Monitor action group](https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/action-groups) to register the Logic App trigger URL with as a webhook receiver. Use the `trigger_callback_url` output for this.

## Usage

```hcl
module "logic_app_slack_alert" {
  source = "../../../dtos-devops-templates/infrastructure/modules/logic-app-slack-alert"

  name                = "logic-slack-alert-myapp-dev-uks"
  resource_group_name = azurerm_resource_group.main.name
  location            = "uksouth"
  slack_webhook_url   = data.azurerm_key_vault_secret.slack_webhook.value
}

resource "azurerm_monitor_action_group" "slack" {
  name                = "ag-slack-myapp-dev-uks"
  resource_group_name = azurerm_resource_group.main.name
  short_name          = "slack"

  webhook_receiver {
    name                    = "logic-app-slack"
    service_uri             = module.logic_app_slack_alert.trigger_callback_url
    use_common_alert_schema = true
  }
}
```

Then attach the action group to any Azure Monitor alert rule:

```hcl
resource "azurerm_monitor_metric_alert" "example" {
  # ...
  action {
    action_group_id = azurerm_monitor_action_group.slack.id
  }
}
```

## Slack message format

Each alert posts a Block Kit message to the configured channel containing:

| Field | Source |
|-------|--------|
| Header | Alert rule name, prefixed with 🚨 (fired) or ✅ (resolved) |
| Severity | `Sev0`–`Sev4` from the alert essentials |
| Status | `Fired` or `Resolved` |
| Fired At | UTC timestamp from the alert payload |
| Resource | First configuration item (affected resource name) |
| Description | Alert rule description |
| Link | Deep link to the Failures blade (App Insights alerts) or the resource overview (all other alert types) |

## Common alert schema

The Logic App trigger is configured to accept the [Azure Monitor common alert schema](https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-common-schema). Ensure `use_common_alert_schema = true` is set on the action group webhook receiver (as shown in the usage example above), otherwise the trigger will reject the payload.

## Webhook URL security

The `trigger_callback_url` output is marked `sensitive`. It contains a SAS token that grants the ability to trigger the Logic App — treat it like a secret. Azure regenerates this URL if the Logic App is recreated.

The `slack_webhook_url` is stored as a `SecureString` workflow parameter in the Logic App, meaning it does not appear in the run history or trigger inputs in the Azure portal.
