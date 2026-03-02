# nat-gateway

Deploy an [Azure NAT gateway](https://learn.microsoft.com/en-us/azure/nat-gateway/nat-overview) with a dedicated public IP address. Provides explicit outbound connectivity for subnets whose VMs have no public IP addresses.

## Terraform documentation

For the list of inputs, outputs, resources... check the [terraform module documentation](tfdocs.md).

## Prerequisites

The subnet must already exist. Use the [subnet module](../subnet/) to create it and pass the resulting subnet ID to this module.

> **Note:** Default outbound access for VMs was retired by Microsoft in September 2025. A NAT gateway (or equivalent) is required for any subnet that needs outbound internet connectivity.

## Usage

```hcl
module "nat_gateway" {
  source = "../../../dtos-devops-templates/infrastructure/modules/nat-gateway"

  name                = "nat-myapp-dev-uks"
  public_ip_name      = "pip-nat-myapp-dev-uks"
  resource_group_name = azurerm_resource_group.main.name
  location            = "uksouth"
  subnet_id           = module.subnet_servers.id
}
```

## Zones

Azure NAT gateway supports a single availability zone (zonal) or no zone pinning (regional). It does not support zone-redundant deployment across multiple zones. Pass a single zone for a zonal deployment:

```hcl
module "nat_gateway" {
  ...
  zones = ["1"]
}
```

An empty list (the default) deploys the NAT gateway without zone pinning.

## Idle timeout

The TCP idle timeout defaults to 4 minutes. Increase it for workloads with long-lived connections:

```hcl
module "nat_gateway" {
  ...
  idle_timeout_in_minutes = 10
}
```

Valid range is 4–120 minutes.

## Monitoring

NAT gateway does not support Azure Monitor diagnostic settings. Metrics such as SNAT connection count, dropped packets, and throughput are available natively in the Azure portal under the resource's Metrics blade.
