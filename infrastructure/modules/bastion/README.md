# bastion

Deploy an [Azure Bastion host](https://learn.microsoft.com/en-us/azure/bastion/bastion-overview) with a dedicated public IP address and diagnostic settings. Integrates with the [subnet module](../subnet/) and [log-analytics-workspace module](../log-analytics-workspace/).

## Terraform documentation

For the list of inputs, outputs, resources... check the [terraform module documentation](tfdocs.md).

## Prerequisites

Azure Bastion requires a dedicated subnet named exactly `AzureBastionSubnet` with a minimum `/26` prefix. Use the [subnet module](../subnet/) to create it with the required NSG rules:

```hcl
module "subnet_bastion" {
  source = "../subnet"

  name                = "AzureBastionSubnet"
  resource_group_name = azurerm_resource_group.main.name
  vnet_name           = module.vnet.name
  address_prefixes    = [cidrsubnet(var.vnet_address_space, 10, 0)]
  location            = var.region
  create_nsg          = true
  network_security_group_name      = "nsg-bastion-${var.env_config}-uks"
  network_security_group_nsg_rules = local.bastion_nsg_rules

  log_analytics_workspace_id                                     = module.log_analytics_workspace.id
  monitor_diagnostic_setting_network_security_group_enabled_logs = []
}
```

See [Azure Bastion NSG requirements](https://learn.microsoft.com/en-us/azure/bastion/bastion-nsg) for the required inbound and outbound rules.

## Usage

Deploy a Standard Bastion host with audit logging:

```hcl
module "bastion" {
  source = "../../../dtos-devops-templates/infrastructure/modules/bastion"

  name                = "bas-myapp-dev-uks"
  public_ip_name      = "pip-bastion-myapp-dev-uks"
  resource_group_name = azurerm_resource_group.main.name
  location            = "uksouth"
  sku                 = "Standard"
  subnet_id           = module.subnet_bastion.id

  log_analytics_workspace_id                      = module.log_analytics_workspace.id
  monitor_diagnostic_setting_bastion_enabled_logs = ["BastionAuditLogs"]
  monitor_diagnostic_setting_bastion_metrics      = ["AllMetrics"]
}
```

## SKU selection

| SKU | Scale units | Native client | File copy | IP connect | Session recording | Public IP required |
|-----|-------------|---------------|-----------|------------|-------------------|--------------------|
| Basic | Fixed (2) | No | No | No | No | Yes |
| Standard | 2–50 | Yes | Yes | Yes | No | Yes |
| Premium | 2–50 | Yes | Yes | Yes | Yes | Yes |

- **Standard** is recommended for most production workloads. It supports native client connections, host scaling, and all advanced features.
- **Premium** adds session recording for compliance requirements and a private-only deployment option (no public IP).
- **Basic** provides a fixed-capacity dedicated deployment at lower cost. Advanced features are not available.
- **Developer** SKU is not supported by this module — it uses shared infrastructure and does not require a public IP or dedicated subnet.

## Zone redundancy (recommended for production)

By default the public IP is deployed with no availability zone pinning. For production, pass `zones = ["1", "2", "3"]` to make the public IP zone-redundant:

```hcl
module "bastion" {
  ...
  zones = ["1", "2", "3"]
}
```

Zone-redundant public IPs are available in UK South at no additional cost. See [Reliability in Azure Bastion](https://learn.microsoft.com/en-us/azure/reliability/reliability-bastion) for supported regions.

## Standard/Premium features

The following features are disabled by default and require Standard SKU or higher:

**Native client / tunneling** — enables SSH and RDP connections via the Azure CLI (`az network bastion ssh`, `az network bastion rdp`) instead of the browser-based client. Recommended for operations teams:

```hcl
module "bastion" {
  ...
  tunneling_enabled = true
}
```

**IP connect** — allows connecting to VMs using their private IP address rather than requiring them to be in the same virtual network:

```hcl
module "bastion" {
  ...
  ip_connect_enabled = true
}
```

**File copy** — enables file transfer between the local machine and target VMs via native client connections:

```hcl
module "bastion" {
  ...
  file_copy_enabled = true
  tunneling_enabled = true  # file copy requires native client
}
```

## Scaling

Each scale unit supports approximately 20 concurrent RDP sessions or 40 concurrent SSH sessions. The default of 2 units (40 RDP / 80 SSH) is sufficient for most environments. Increase `scale_units` for larger deployments:

```hcl
module "bastion" {
  ...
  scale_units = 5  # ~100 concurrent RDP / ~200 concurrent SSH
}
```

`scale_units` is only configurable for Standard and Premium SKUs. Basic is fixed at 2 units.

## Diagnostic logs

The module creates a diagnostic setting targeting the provided Log Analytics workspace. The only available log category for Azure Bastion is `BastionAuditLogs`, which records user connections, source IPs, session metadata, and audit trail information:

```hcl
module "bastion" {
  ...
  monitor_diagnostic_setting_bastion_enabled_logs = ["BastionAuditLogs"]
  monitor_diagnostic_setting_bastion_metrics      = ["AllMetrics"]
}
```
