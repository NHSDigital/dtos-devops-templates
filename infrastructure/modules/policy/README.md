# Terraform Module: Azure Policy Definition
[![CI](https://github.com/nhsdigital/terraform-azurerm-policy-definition/actions/workflows/ci.yaml/badge.svg)](https://github.com/nhsdigital/terraform-azurerm-policy-definition/actions)
[![Terraform](https://img.shields.io/badge/Terraform-Verified-blueviolet?logo=terraform)](https://www.terraform.io/)
[![License](https://img.shields.io/github/license/nhsdigital/terraform-azurerm-policy-definition)](./LICENSE)
[![Azure](https://img.shields.io/badge/Azure-Policy-blue?logo=microsoft-azure)](https://learn.microsoft.com/en-us/azure/governance/policy/overview)

This module allows you to define and deploy custom Azure Policy Definitions using Terraform.


A reusable Terraform module to manage Azure Policy Definitions using the `azurerm_policy_definition` resource.

## ➕ Features

- Declarative policy rule configuration
- Metadata and parameter support
- Tested against Azure using Terratest
- Ready for registry publishing

## 📦 Usage

```hcl
module "example_policy" {
  source = "..."

  name         = "audit-vm-managed-disks"
  display_name = "Audit VMs with unmanaged disks"
  description  = "Audits virtual machines that are not using managed disks."
  policy_rule  = {
    "if" = {
      "field" = "Microsoft.Compute/disks/storageAccountType"
      "notEquals" = "Managed"
    }
    "then" = {
      "effect" = "audit"
    }
  }
}
```

## 📥Inputs

| Name | Type | Default | Description |
|--------------|--------|---------|--------------------------------------|
| `name`         | string | n/a     | The name of the policy definition. |
| `display_name` | string | n/a     | Display name of the policy.        |
| `description`  | string | ""      | Description of the policy.         |
| `policy_rule`  | any    | n/a     | Policy rule map.                   |
| `mode`         | string | "All"   | Policy mode.                       |
| `metadata`     | any    | `{}`    | Metadata block.                    |
| `parameters`   | any    | `{}`    | Parameters block.                  |

## 📤 Outputs

`policy_definition_id` - The ID of the created policy definition.

## ✅ Testing the Module

### **Manual Validation**

1. **Initialize & Validate**

   ```sh
   terraform init
   terraform validate
   ```

1. **Plan and Apply (dev environment)**

   ```sh
    terraform plan -out=tfplan
    terraform apply tfplan
    ```

1. **Verify**
    Use the Azure CLI or Portal to check:

    ```powershell
    az policy definition show --name deny-public-ip
    ```

### Automated Validation

This module uses **Terratest**, a Go-based infrastructure testing framework, to verify that policy definitions are correctly deployed to Azure.

#### Why Terratest?

- It ensures our module provisions _expected resources_
- _Validates output values_ and Azure behavior
- Helps to _catch regressions and breaking changes_
- Improves confidence for reusing the module in different environments

#### Running Terratest Locally

1. Ensure that Go 1.20+ is [installed](https://go.dev/learn/).

1. Navigate to your test directory:

    ```sh
    cd infrastructure/modules/policy
    ```

1. Enable dependency tracking for your code:

    ```sh
    go mod init tests

    go get github.com/gruntwork-io/terratest/modules/terraform
    go get github.com/stretchr/testify/assert
    ```

1. Run the test:

    ```sh
    go test -v
    ```

Example test file (located in tests/policy_test.go)

```go
package test

import (
  "testing"
  "github.com/gruntwork-io/terratest/modules/terraform"
  "github.com/stretchr/testify/assert"
)

func TestPolicyDefinition(t *testing.T) {
  t.Parallel()

  terraformOptions := &terraform.Options{
    TerraformDir: "../examples/simple-policy",
  }

  defer terraform.Destroy(t, terraformOptions)

  terraform.InitAndApply(t, terraformOptions)

  output := terraform.Output(t, terraformOptions, "policy_definition_id")
  assert.Contains(t, output, "/providers/Microsoft.Authorization/policyDefinitions/")
}
```

### 📚 Additional Resources

- [Azure Policy Documentation](https://learn.microsoft.com/en-us/azure/governance/policy/overview)
- [azurerm_policy_definition.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/policy_definition) (resource)
- [Terratest Docs](https://terratest.gruntwork.io/docs/getting-started/quick-start/)
