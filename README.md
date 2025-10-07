# DTOS Devops template

This repository contains terraform modules and Azure devops pipeline steps to deploy DTOS applications.

## Terraform modules
- [acme-certificate](infrastructure/modules/acme-certificate/README.md)
- [api-management](infrastructure/modules/api-management/README.md)
- [app-insights](infrastructure/modules/app-insights/README.md)
- [app-service-plan](infrastructure/modules/app-service-plan/README.md)
- [application-gateway](infrastructure/modules/application-gateway/README.md)
- [baseline](infrastructure/modules/baseline/README.md)
- [cdn-frontdoor-endpoint](infrastructure/modules/cdn-frontdoor-endpoint/README.md)
- [cdn-frontdoor-profile](infrastructure/modules/cdn-frontdoor-profile/README.md)
- [container-app](infrastructure/modules/container-app/README.md)
- [container-app-environment](infrastructure/modules/container-app-environment/README.md)
- [container-app-job](infrastructure/modules/container-app-job/README.md)
- [container-registry](infrastructure/modules/container-registry/README.md)
- [diagnostic-settings](infrastructure/modules/diagnostic-settings/README.md)
- [dns-a-record](infrastructure/modules/dns-a-record/README.md)
- [event-grid-subscription](infrastructure/modules/event-grid-subscription/README.md)
- [event-grid-topic](infrastructure/modules/event-grid-topic/README.md)
- [event-hub](infrastructure/modules/event-hub/README.md)
- [firewall](infrastructure/modules/firewall/README.md)
- [firewall-policy](infrastructure/modules/firewall-policy/README.md)
- [firewall-rule-collection-group](infrastructure/modules/firewall-rule-collection-group/README.md)
- [function-app](infrastructure/modules/function-app/README.md)
- [function-app-slots](infrastructure/modules/function-app-slots/README.md)
- [key-vault](infrastructure/modules/key-vault/README.md)
- [lets-encrypt-certificates](infrastructure/modules/lets-encrypt-certificates/README.md)
- [linux-web-app](infrastructure/modules/linux-web-app/README.md)
- [linux-web-app-slots](infrastructure/modules/linux-web-app-slots/README.md)
- [log-analytics-data-export-rule](infrastructure/modules/log-analytics-data-export-rule/README.md)
- [log-analytics-workspace](infrastructure/modules/log-analytics-workspace/README.md)
- [managed-identity](infrastructure/modules/managed-identity/README.md)
- [monitor-action-group](infrastructure/modules/monitor-action-group/README.md)
- [network-security-group](infrastructure/modules/network-security-group/README.md)
- [postgresql-flexible](infrastructure/modules/postgresql-flexible/README.md)
- [private-dns-a-record](infrastructure/modules/private-dns-a-record/README.md)
- [private-dns-zone](infrastructure/modules/private-dns-zone/README.md)
- [private-dns-zone-resolver](infrastructure/modules/private-dns-zone-resolver/README.md)
- [private-endpoint](infrastructure/modules/private-endpoint/README.md)
- [private-link-scoped-service](infrastructure/modules/private-link-scoped-service/README.md)
- [public-ip](infrastructure/modules/public-ip/README.md)
- [rbac-assignment](infrastructure/modules/rbac-assignment/README.md)
- [route-table](infrastructure/modules/route-table/README.md)
- [service-bus](infrastructure/modules/service-bus/README.md)
- [shared-config](infrastructure/modules/shared-config/README.md)
- [sql-server](infrastructure/modules/sql-server/README.md)
- [storage](infrastructure/modules/storage/README.md)
- [subnet](infrastructure/modules/subnet/README.md)
- [virtual-desktop](infrastructure/modules/virtual-desktop/README.md)
- [vnet](infrastructure/modules/vnet/README.md)
- [vnet-peering](infrastructure/modules/vnet-peering/README.md)

## Update terraform documentation
After working on terraform modules, always update the terraform documentation by running:

```shell
brew install terraform-docs
make terraform-docs
```

For each module, add a description to the README. Add basic usage to the README. If the code is more involved, add example code to the `examples/` directory instead.

Make sure to link all modules from this README.


## Alerts

To enable alerting (example here on container app)
- Set `enable_alerting = true`.
- Severity are 0 = Critical, 1 = Error, 2 = Warning, 3 = informational and 4 = verbose

Example:
```hcl
module "postgres" {
  ...
  enable_alerting                 = true
  action_group_id                 = <action_group_id>
  alert_memory_threshold          = 80 (already defaults to this)
  alert_cpu_threshold             = 80 (already defaults to this)
  alert_storage_threshold         =  (already defaults to this)
}
```
