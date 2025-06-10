module "example_policy_definition_deny_public_ip" {
  source       = "../policy-definition"
  name         = "deny-public-ip"
  display_name = "Deny Public IP"
  description  = "Denies creation of public IP addresses"
  policy_rule = {
    if = {
      field  = "type"
      equals = "Microsoft.Network/publicIPAddresses"
    }
    then = {
      effect = "deny"
    }
  }
  metadata = {
    owner = "platform@nhs.net"
  }
}

module "example_policy_assignment_deny_public_ip" {
  source                         = "../policy-assignments"
  assignment_name                = "deny-public-ip"
  display_name                   = "Deny Public IP Assignment"
  description                    = "Assigns the deny-public-ip policy to the dev subscription"
  policy_assignment_scope        = "/subscriptions/11111111-1111-1111-1111-111111111111"
  policy_assignment_principal_id = ""
  policy_definition_id           = module.example_policy_definition_deny_public_ip.policy_definition_id
}

module "example_policy_initiative_security" {
  source       = "../policy-initiatives"
  name         = "security-controls"
  display_name = "Security Controls Initiative"
  description  = "Combines core security policies"
  policy_type  = "custom"
  policy_definitions = [
    {
      id           = module.example_policy_definition_deny_public_ip.policy_definition_id
      reference_id = "denyPublicIP"
    }
  ]
}

module "example_policy_remediation" {
  source = "../policy-remediation"

  policy_assignment_scope        = ""
  policy_assignment_principal_id = ""
}
