# container-app

Deploy an [Azure container app job](https://learn.microsoft.com/en-us/azure/container-apps/jobs) to a [Container app environment](https://learn.microsoft.com/en-us/azure/container-apps/environment) in order to run container workloads that do not require ingress or web access. The container app job can be triggered manually or via an event source, such as a timer or message queue. The job will not automatically run following deployment or update of the resources and the job can stop upon completion if the application code contains an exit code. It can be run again on demand via the Azure portal, CLI, or API.

Integrates with the [container-app-environment module](../container-app-environment/).

See also the following ADO template step that can be used to trigger a container app job run: [app-container-job-start.yaml](../../../.azuredevops/templates/steps/app-container-job-start.yaml).

## Terraform documentation
For the list of inputs, outputs, resources... check the [terraform module documentation](tfdocs.md).

## Usage
Create the common container app environment:
```hcl
module "container-app-environment" {
  source = "../../../dtos-devops-templates/infrastructure/modules/container-app-environment"

  name                       = "manage-breast-screening-${var.environment}"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  log_analytics_workspace_id = data.terraform_remote_state.audit.outputs.log_analytics_workspace_id
  vnet_integration_subnet_id = module.container_app_subnet.id
}
```

Create a container app job to run an image pulled from Azure Container Registry (ACR). The job will run in the container app environment and can be triggered manually, via a cron schedule or via an event source:
```hcl
module "container-app-job" {

  source = "../../../dtos-devops-templates/infrastructure/modules/container-app-job"

  name                         = "ca-workload-name-${var.environment}"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  container_app_environment_id = module.container-app-environment.id

  # List of user assigned managed identities to assign to the container app job so it can authenticate against e.g. database, key vault, etc:
  user_assigned_identity_ids   = var.user_assigned_identity_ids

  acr_login_server        = data.azurerm_container_registry.acr.login_server
  acr_managed_identity_id = var.acr_managed_identity_id
  docker_image            = "${data.azurerm_container_registry.acr.login_server}/${var.docker_image}:${var.docker_env_tag}"

  environment_variables = {
    "ENVIRONMENT_VAR" = var.environment_var
  }
}
```

