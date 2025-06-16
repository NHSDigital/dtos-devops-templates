locals {
  resource_id= "<provide the ID of a resource to assign this policy definition to>"

  # See Policy Limitations
  # https://docs.azure.cn/en-us/governance/policy/concepts/definition-structure-policy-rule#policy-rule-limits

  # Enforce a arbitrary 'max'
  max_tags = 32

  # We're looping here to automatically build up the policy rule's parameters, conditions and operations
  tag_params = {
    for i, tag in slice(var.tags, 0, min(length(var.tags), local.max_tags)) :
    "tag${i + 1}" => {
      type     = "String"
      metadata = {
        displayName = "Tag ${i + 1}"
        description = "Name of tag ${i + 1} to inherit from resource group"
      }
    }
  }

  # How we check for the presence of the tag
  tag_conditions = [
    for i, tag in slice(var.tags, 0, min(length(var.tags), local.max_tags)) : {
      field  = "[concat('tags[', parameters('tag${i + 1}'), ']')]"
      exists = "false"
    }
  ]

  # What do we do if the tag is missing
  tag_operations = [
    for i, tag in slice(var.tags, 0, min(length(var.tags), local.max_tags)) : {
      operation = "add"
      field     = "[concat('tags[', parameters('tag${i + 1}'), ']')]"
      value     = "[resourceGroup().tags[parameters('tag${i + 1}')]]"
    }
  ]

  tag_values = {
    for i, tag in slice(var.tags, 0, min(length(var.tags), local.max_tags)) :
    "tag${i + 1}" => {
      value = tag
    }
  }
}


