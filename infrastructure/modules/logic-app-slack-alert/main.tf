resource "azurerm_logic_app_workflow" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  workflow_parameters = {
    "slackWebhookUrl" = jsonencode({
      type         = "SecureString"
      defaultValue = ""
    })
  }

  parameters = {
    "slackWebhookUrl" = var.slack_webhook_url
  }
}

resource "azurerm_logic_app_trigger_http_request" "this" {
  name         = "When_an_HTTP_request_is_received"
  logic_app_id = azurerm_logic_app_workflow.this.id
  method       = "POST"

  schema = jsonencode({
    "$schema" = "http://json-schema.org/draft-04/schema#"
    type      = "object"
    properties = {
      schemaId = { type = "string" }
      data = {
        type = "object"
        properties = {
          essentials = {
            type = "object"
            properties = {
              alertRule        = { type = "string" }
              severity         = { type = "string" }
              firedDateTime    = { type = "string" }
              resolvedDateTime = { type = "string" }
              monitorCondition = { type = "string" }
              description      = { type = "string" }
              alertTargetIDs = {
                type  = "array"
                items = { type = "string" }
              }
              configurationItems = {
                type  = "array"
                items = { type = "string" }
              }
            }
          }
        }
      }
    }
  })
}

resource "azurerm_logic_app_action_custom" "post_to_slack" {
  name         = "Post_to_Slack"
  logic_app_id = azurerm_logic_app_workflow.this.id

  body = <<-BODY
    {
      "type": "Http",
      "inputs": {
        "method": "POST",
        "uri": "@parameters('slackWebhookUrl')",
        "headers": {
          "Content-Type": "application/json"
        },
        "body": {
          "blocks": [
            {
              "type": "header",
              "text": {
                "type": "plain_text",
                "text": "@{concat(if(equals(triggerBody()?['data']?['essentials']?['monitorCondition'], 'Resolved'), concat('✅ ', triggerBody()?['data']?['essentials']?['severity'], ' resolved'), concat('🚨 ', triggerBody()?['data']?['essentials']?['severity'], ' alert')), ' – ', triggerBody()?['data']?['essentials']?['alertRule'], if(empty(coalesce(triggerBody()?['data']?['essentials']?['configurationItems']?[0], '')), '', concat(' (resource: `', triggerBody()?['data']?['essentials']?['configurationItems']?[0], '`)')))}",
                "emoji": true
              }
            },
            {
              "type": "section",
              "text": {
                "type": "mrkdwn",
                "text": "@{concat('*Description*\n> ', coalesce(triggerBody()?['data']?['essentials']?['description'], 'N/A'))}"
              }
            },
            {
              "type": "section",
              "text": {
                "type": "mrkdwn",
                "text": "@{if(contains(coalesce(triggerBody()?['data']?['essentials']?['alertTargetIDs']?[0], ''), 'microsoft.insights/components'), concat(':mag: <https://portal.azure.com/#resource', triggerBody()?['data']?['essentials']?['alertTargetIDs']?[0], '/failures|View Failures in App Insights>'), concat(':mag: <https://portal.azure.com/#resource', coalesce(triggerBody()?['data']?['essentials']?['alertTargetIDs']?[0], ''), '|View Resource in Azure Portal>'))}"
              }
            }
          ]
        }
      },
      "runAfter": {}
    }
  BODY

  depends_on = [azurerm_logic_app_trigger_http_request.this]
}
