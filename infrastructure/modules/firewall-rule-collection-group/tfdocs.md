# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_firewall_policy_id"></a> [firewall\_policy\_id](#input\_firewall\_policy\_id)

Description: The ID of the Firewall Policy.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the firewall network rule.

Type: `string`

### <a name="input_priority"></a> [priority](#input\_priority)

Description: The priority of the rule.

Type: `number`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_application_rule_collection"></a> [application\_rule\_collection](#input\_application\_rule\_collection)

Description: List of application rule collections

Type:

```hcl
list(object({
    name      = optional(string)
    priority  = optional(number)
    action    = optional(string)
    rule_name = optional(string)
    protocols = list(object({
      type = optional(string)
      port = optional(string)
    }))
    source_addresses  = optional(list(string))
    destination_fqdns = optional(list(string))
  }))
```

Default: `[]`

### <a name="input_nat_rule_collection"></a> [nat\_rule\_collection](#input\_nat\_rule\_collection)

Description: List of nat rule collections

Type:

```hcl
list(object({
    name                = optional(string)
    priority            = optional(number)
    action              = optional(string)
    rule_name           = optional(string)
    translated_address  = optional(string)
    source_addresses    = optional(list(string))
    destination_address = optional(string)
    protocols           = optional(list(string))
    destination_ports   = optional(list(string))
    translated_port     = optional(string)
  }))
```

Default: `[]`

### <a name="input_network_rule_collection"></a> [network\_rule\_collection](#input\_network\_rule\_collection)

Description: List of network rule collections

Type:

```hcl
list(object({
    name                  = optional(string)
    priority              = optional(number)
    action                = optional(string)
    rule_name             = optional(string)
    source_addresses      = optional(list(string))
    destination_addresses = optional(list(string))
    protocols             = optional(list(string))
    destination_ports     = optional(list(string))
  }))
```

Default: `[]`


## Resources

The following resources are used by this module:

- [azurerm_firewall_policy_rule_collection_group.policy_rule_collection_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall_policy_rule_collection_group) (resource)
