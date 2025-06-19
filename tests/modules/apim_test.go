package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// getBaseTerraformOptions returns a base configuration that can be reused in tests.
func getBaseTerraformOptions(vars map[string]interface{}) *terraform.Options {
	// Default vars
	defaultVars := map[string]interface{}{
		"name":         "apim-default",
		"location":     "uksouth",
		"resource_group_name":  "rg-test",
		"client_secret": "asecret",
		"client_id":  "123",
		"log_analytics_workspace_id":  "123",
		"sku_capacity": 1,
		"sku_name":     "Developer",
		"zones": []interface{}{},
		"additional_locations": []interface{}{},
		"certificate_details": []interface{}{},
		"publisher_name": "Example Ltd.",
		"publisher_email": "email@example.com",
		"virtual_network_type": "Internal",
		"virtual_network_configuration": []string{
			"/subscriptions/xxx/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/subnet",
		},
		"public_ip_address_id": "/subscriptions/xxx/resourceGroups/rg/providers/Microsoft.Network/publicIPAddresses/ip",
		"tags": map[string]string{
			"environment": "test",
		},
	}

	// Override defaults with any test-specific values
	for key, value := range vars {
		defaultVars[key] = value
	}

	return &terraform.Options{
		TerraformDir: "../../infrastructure/modules/api-management",
		Vars:         defaultVars,
		NoColor:      true,
		TerraformBinary:  "terraform",
	}
}

func TestInvalidSkuCapacity(t *testing.T) {
	t.Parallel()

	tfOptions := getBaseTerraformOptions(map[string]interface{}{
		"name":         "apim-invalid-capacity",
		"sku_capacity": 15,
	})

	terraformOptions := terraform.WithDefaultRetryableErrors(t, tfOptions)

	_, err := terraform.InitAndPlanE(t, terraformOptions)

	assert.Error(t, err)
	assert.Contains(t, err.Error(), "The SKU capacity must be a positive integer less than 10.")
}

func TestInvalidSkuName(t *testing.T) {
	t.Parallel()

	tfOptions := getBaseTerraformOptions(map[string]interface{}{
		"name":      "apim-invalid-skuname",
		"sku_name":  "MadeUpName",
	})

	terraformOptions := terraform.WithDefaultRetryableErrors(t, tfOptions)

	_, err := terraform.InitAndPlanE(t, terraformOptions)

	assert.Error(t, err)
	assert.Contains(t, err.Error(), "The SKU name must be either Consumption, Developer, Basic, Standard")
}

func TestInvalidName(t *testing.T) {
	t.Parallel()

	// e.g. starts with a hyphen (invalid) and longer than 50 chars
	invalidName := "-invalid-name-"
	tfOptions := getBaseTerraformOptions(map[string]interface{}{
			"name": invalidName,
	})

	terraformOptions := terraform.WithDefaultRetryableErrors(t, tfOptions)

	_, err := terraform.InitAndPlanE(t, terraformOptions)

	assert.Error(t, err)
	assert.Contains(t, err.Error(),
			"The API Management service name must be between 1 and 50 characters")
}

func TestInvalidIdentityType(t *testing.T) {
	t.Parallel()

	// e.g. starts with a hyphen (invalid) and longer than 50 chars
	invalidIdentityType := "invalidIdentity"
	tfOptions := getBaseTerraformOptions(map[string]interface{}{
			"identity_type": invalidIdentityType,
	})

	terraformOptions := terraform.WithDefaultRetryableErrors(t, tfOptions)

	_, err := terraform.InitAndPlanE(t, terraformOptions)

	assert.Error(t, err)
	assert.Contains(t, err.Error(),
			"The identity type must be either SystemAssigned, UserAssigned,")
}

func TestInvalidPublisherEmail(t *testing.T) {
	t.Parallel()

	// e.g. starts with a hyphen (invalid) and longer than 50 chars
	invalidPublisherEmail := "invalidEmail"
	tfOptions := getBaseTerraformOptions(map[string]interface{}{
			"publisher_email": invalidPublisherEmail,
	})

	terraformOptions := terraform.WithDefaultRetryableErrors(t, tfOptions)

	_, err := terraform.InitAndPlanE(t, terraformOptions)

	assert.Error(t, err)
	assert.Contains(t, err.Error(),
			"The publisher email address is not valid.")
}


func TestInvalidVirtualNetworkType(t *testing.T) {
	t.Parallel()

	// e.g. starts with a hyphen (invalid) and longer than 50 chars
	invalidVirtualNetworkType := "invalidNetworkType"
	tfOptions := getBaseTerraformOptions(map[string]interface{}{
			"virtual_network_type": invalidVirtualNetworkType,
	})

	terraformOptions := terraform.WithDefaultRetryableErrors(t, tfOptions)

	_, err := terraform.InitAndPlanE(t, terraformOptions)

	assert.Error(t, err)
	assert.Contains(t, err.Error(),
			"The virtual network type must be either None, External or Internal.")
}
