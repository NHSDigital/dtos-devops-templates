# relay-hybrid-connection

Deploy an [Azure Relay Hybrid Connection](https://learn.microsoft.com/en-us/azure/azure-relay/relay-hybrid-connections-protocol) to enable secure, bi-directional communication between on-premises applications and Azure services through an existing Azure Relay namespace.

This module creates:
- Azure Relay Hybrid Connection
- Optional authorization rules with configurable permissions (Listen, Send, Manage)

**Note:** This module requires an existing Azure Relay namespace. Use the `relay-namespace` module to create the namespace first.

## Terraform documentation
For the list of inputs, outputs, resources... check the [terraform module documentation](tfdocs.md).

## Usage

### Basic usage (without authorization rules)
```hcl
module "relay_hybrid_connection" {
  source = "../../../dtos-devops-templates/infrastructure/modules/relay-hybrid-connection"

  name                 = "hc-${var.application}-${var.environment}"
  relay_namespace_name = module.relay_namespace.name
  resource_group_name  = var.resource_group_name
}
```

### With authorization rules
```hcl
module "relay_hybrid_connection" {
  source = "../../../dtos-devops-templates/infrastructure/modules/relay-hybrid-connection"

  name                          = "hc-${var.application}-${var.environment}"
  relay_namespace_name          = module.relay_namespace.name
  resource_group_name           = var.resource_group_name
  requires_client_authorization = true
  user_metadata                 = "Application hybrid connection"

  authorization_rules = {
    "listen-rule" = {
      listen = true
      send   = false
      manage = false
    }
    "send-rule" = {
      listen = false
      send   = true
      manage = false
    }
    "manage-rule" = {
      listen = true
      send   = true
      manage = true
    }
  }
}
```

### Complete example with namespace
```hcl
# Create the relay namespace first
module "relay_namespace" {
  source = "../../../dtos-devops-templates/infrastructure/modules/relay-namespace"

  name                       = "relay-${var.application}-${var.environment}"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  log_analytics_workspace_id = data.terraform_remote_state.audit.outputs.log_analytics_workspace_id

  tags = var.tags
}

# Create hybrid connection with authorization rules
module "relay_hybrid_connection" {
  source = "../../../dtos-devops-templates/infrastructure/modules/relay-hybrid-connection"

  name                 = "hc-${var.application}-${var.environment}"
  relay_namespace_name = module.relay_namespace.name
  resource_group_name  = var.resource_group_name

  authorization_rules = {
    "app-listener" = {
      listen = true
    }
    "app-sender" = {
      send = true
    }
  }
}
```

## Naming constraints

The Azure Relay Hybrid Connection name must follow these rules:

| Constraint | Requirement |
|------------|-------------|
| Length | 1-260 characters |
| Start | Must start with a letter or number |
| End | Must end with a letter or number |
| Characters | Letters, numbers, hyphens, underscores, and periods |

Authorization rule names follow similar constraints (1-256 characters).

## Authorization rules

Authorization rules support three permission types:

| Permission | Description |
|------------|-------------|
| `listen` | Allows receiving messages from the hybrid connection |
| `send` | Allows sending messages to the hybrid connection |
| `manage` | Allows managing the hybrid connection (requires both `listen` and `send` to be `true`) |

**Note:** When `manage = true`, both `listen` and `send` must also be set to `true`. The module validates this constraint.

## Outputs

| Output | Description |
|--------|-------------|
| `name` | The name of the Hybrid Connection |
| `id` | The resource ID of the Hybrid Connection |
| `authorization_rule_ids` | Map of authorization rule names to their IDs |
| `authorization_rule_primary_keys` | Map of authorization rule names to their primary keys (sensitive) |
| `authorization_rule_secondary_keys` | Map of authorization rule names to their secondary keys (sensitive) |
| `authorization_rule_primary_connection_strings` | Map of authorization rule names to their primary connection strings (sensitive) |
| `authorization_rule_secondary_connection_strings` | Map of authorization rule names to their secondary connection strings (sensitive) |
