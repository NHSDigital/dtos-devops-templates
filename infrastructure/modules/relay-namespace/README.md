# relay-namespace

Deploy an [Azure Relay namespace](https://learn.microsoft.com/en-us/azure/azure-relay/relay-what-is-it) to enable secure hybrid connections between on-premises resources and Azure services. Azure Relay facilitates communication without requiring firewall changes or intrusive changes to corporate network infrastructure.

This module creates:
- Azure Relay namespace
- Optional private endpoint for secure connectivity
- Diagnostic settings for monitoring and logging

**Note:** This module only creates the namespace. Hybrid connections and authorization rules should be created separately using the [relay-hybrid-connection](../relay-hybrid-connection/README.md) module to support the pattern of one namespace with many hybrid connections.

## Private DNS Zone

Azure Relay uses the same private DNS zone as Service Bus: `privatelink.servicebus.windows.net`. Ensure this DNS zone is configured when enabling private endpoints.

## Terraform documentation
For the list of inputs, outputs, resources... check the [terraform module documentation](tfdocs.md).

## Usage

### Basic usage (without private endpoint)
```hcl
module "relay_namespace" {
  source = "../../../dtos-devops-templates/infrastructure/modules/relay-namespace"

  name                = "relay-${var.application}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location

  log_analytics_workspace_id = data.terraform_remote_state.audit.outputs.log_analytics_workspace_id

  tags = var.tags
}
```

### With private endpoint
```hcl
module "relay_namespace" {
  source = "../../../dtos-devops-templates/infrastructure/modules/relay-namespace"

  name                = "relay-${var.application}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location

  log_analytics_workspace_id = data.terraform_remote_state.audit.outputs.log_analytics_workspace_id

  private_endpoint_properties = {
    private_endpoint_enabled             = true
    private_endpoint_subnet_id           = module.private_endpoint_subnet.id
    private_endpoint_resource_group_name = var.network_resource_group_name
    private_dns_zone_ids_relay           = [data.azurerm_private_dns_zone.servicebus.id]
  }

  tags = var.tags
}
```

## Naming constraints

The Azure Relay namespace name must follow these rules:

| Constraint | Requirement |
|------------|-------------|
| Length | 6-50 characters |
| Start | Must start with a letter |
| End | Must end with a letter or number |
| Characters | Letters, numbers, and hyphens only |
| Uniqueness | Globally unique (creates `<name>.servicebus.windows.net`) |

## Outputs

| Output | Description |
|--------|-------------|
| `name` | The name of the Relay namespace |
| `id` | The resource ID of the Relay namespace |
| `primary_connection_string` | Primary connection string (sensitive) |
| `secondary_connection_string` | Secondary connection string (sensitive) |
| `primary_key` | Primary access key (sensitive) |
| `secondary_key` | Secondary access key (sensitive) |
