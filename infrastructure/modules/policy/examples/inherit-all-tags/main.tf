module "create_inherit_tag_policy"{
  source = "../../policy-definition"
  policy_name         = "testpolicy"
  policy_effect = "modify"
  display_name = "policy display name"
  description  = "no laughing matter this is"

  policy_type  = "Custom"
  mode         = "Indexed"

  parameters  = local.tag_values

}

