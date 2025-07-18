#
# Note: for custom role definition resources, don't use the "id" property.
#
# "id"" is a Terraform property in the format "<id>|<scope>". Instead use
# the role_definition_resource_id property (the ARM ID)
#

output "role_definition_id" {
  value = module.global_role_definition_rw.role_definition_id
}


