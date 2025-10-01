# Application Insights availability test

Deploy an [Azure application insights avaliability test](https://learn.microsoft.com/en-us/azure/azure-monitor/app/availability?tabs=standard) to continuously monitor the accessibility of a web endpoint. The test periodically sends requests to a specified URL from multiple Azure locations and records response times, status codes, and any failures.

The availability test runs automatically at the configured frequency once deployed and provides visibility into uptime, latency, and dependency issues through [Application insights](https://learn.microsoft.com/en-us/azure/azure-monitor/app/usage?tabs=users) and Azure Monitor.
Integrates with the  module.

See also the following ADO template step that can be used to verify endpoint health as part of a release pipeline: app-insights-availability-check.yaml.


## Terraform documentation
For the list of inputs, outputs, resources... check the [terraform module documentation](tfdocs.md).

## Usage
Create the application Insights availability test:
```hcl
module "azurerm_application_insights_standard_web_test" {
  source = "../dtos-devops-templates/infrastructure/modules/application-insights-availability-test"

  name                       = "${var.app_short_name}-web-${var.environment}"
  resource_group_name        = var.resource_group_name_infra
  application_insights_id    = data.azurerm_log_analytics_workspace.audit[0].id
  target_url                 = "${module.container-apps[0].external_url}healthcheck/"
}
```
