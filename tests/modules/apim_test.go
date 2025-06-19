package test

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// injectProviderFile creates a temporary provider.tf file in the module directory.
func injectProviderFile(dir string, t *testing.T) {
	providerContent := `provider "azurerm" {
  features {}
}
`
	providerPath := filepath.Join(dir, "provider_test.tf")
	err := os.WriteFile(providerPath, []byte(providerContent), 0644)
	if err != nil {
		t.Fatalf("failed to write provider file: %v", err)
	}
}

func getBaseTerraformOptions(vars map[string]interface{}, t *testing.T) *terraform.Options {
	moduleDir := "../../infrastructure/modules/api-management"

	// Inject provider file
	injectProviderFile(moduleDir, t)

	defaultVars := map[string]interface{}{
		"name":                     "apim-default",
		"location":                 "uksouth",
		"resource_group_name":      "rg-test",
		"client_secret":            "asecret",
		"client_id":                "123",
		"log_analytics_workspace_id": "123",
		"sku_capacity":             1,
		"sku_name":                 "Developer",
		"zones":                    []interface{}{},
		"additional_locations":     []interface{}{},
		"certificate_details":      []interface{}{},
		"publisher_name":           "Example Ltd.",
		"publisher_email":          "email@example.com",
		"virtual_network_type":     "Internal",
		"virtual_network_configuration": []string{
			"/subscriptions/xxx/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/subnet",
		},
		"public_ip_address_id": "/subscriptions/xxx/resourceGroups/rg/providers/Microsoft.Network/publicIPAddresses/ip",
		"tags": map[string]string{
			"environment": "test",
		},
	}

	for key, value := range vars {
		defaultVars[key] = value
	}

	return &terraform.Options{
		TerraformDir:    moduleDir,
		Vars:            defaultVars,
		NoColor:         true,
		TerraformBinary: "terraform",
	}
}

func TestInvalidSkuCapacity(t *testing.T) {
	t.Parallel()
	tfOptions := getBaseTerraformOptions(map[string]interface{}{
		"name":         "apim-invalid-capacity",
		"sku_capacity": 15,
	}, t)

	_, err := terraform.InitAndPlanE(t, terraform.WithDefaultRetryableErrors(t, tfOptions))

	assert.Error(t, err)
	assert.Contains(t, err.Error(), "The SKU capacity must be a positive integer less than 10.")
}

func TestInvalidSkuName(t *testing.T) {
	t.Parallel()
	tfOptions := getBaseTerraformOptions(map[string]interface{}{
		"name":     "apim-invalid-skuname",
		"sku_name": "MadeUpName",
	}, t)

	_, err := terraform.InitAndPlanE(t, terraform.WithDefaultRetryableErrors(t, tfOptions))

	assert.Error(t, err)
	assert.Contains(t, err.Error(), "The SKU name must be either Consumption, Developer, Basic, Standard")
}

func TestInvalidName(t *testing.T) {
	t.Parallel()
	tfOptions := getBaseTerraformOptions(map[string]interface{}{
		"name": "-invalid-name-",
	}, t)

	_, err := terraform.InitAndPlanE(t, terraform.WithDefaultRetryableErrors(t, tfOptions))

	assert.Error(t, err)
	assert.Contains(t, err.Error(), "The API Management service name must be between 1 and 50 characters")
}

func TestInvalidIdentityType(t *testing.T) {
	t.Parallel()
	tfOptions := getBaseTerraformOptions(map[string]interface{}{
		"identity_type": "invalidIdentity",
	}, t)

	_, err := terraform.InitAndPlanE(t, terraform.WithDefaultRetryableErrors(t, tfOptions))

	assert.Error(t, err)
	assert.Contains(t, err.Error(), "The identity type must be either SystemAssigned, UserAssigned,")
}

func TestInvalidPublisherEmail(t *testing.T) {
	t.Parallel()
	tfOptions := getBaseTerraformOptions(map[string]interface{}{
		"publisher_email": "invalidEmail",
	}, t)

	_, err := terraform.InitAndPlanE(t, terraform.WithDefaultRetryableErrors(t, tfOptions))

	assert.Error(t, err)
	assert.Contains(t, err.Error(), "The publisher email address is not valid.")
}

func TestInvalidVirtualNetworkType(t *testing.T) {
	t.Parallel()
	tfOptions := getBaseTerraformOptions(map[string]interface{}{
		"virtual_network_type": "invalidNetworkType",
	}, t)

	_, err := terraform.InitAndPlanE(t, terraform.WithDefaultRetryableErrors(t, tfOptions))

	assert.Error(t, err)
	assert.Contains(t, err.Error(), "The virtual network type must be either None, External or Internal.")
}
