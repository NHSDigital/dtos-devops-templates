package test

import (
	"fmt"
	"os"
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/files"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func setupTestModule(t *testing.T, vars map[string]any) string {
	moduleDir := "../"

	tempDir, err := files.CopyTerraformFolderToTemp(moduleDir, t.Name())
	if err != nil {
		tempDir = t.TempDir()
		copyTerraformFiles(t, moduleDir, tempDir)
	}

	// We only need to inject the provider block, as required_providers is now in versions.tf
	providerContent := "provider \"azurerm\" {\nfeatures {}\n}\n"
	providerPath := filepath.Join(tempDir, "provider_test.tf")
	err = os.WriteFile(providerPath, []byte(providerContent), 0644)
	if err != nil {
		t.Fatalf("failed to write provider file: %v", err)
	}

	writeVarsFile(t, tempDir, vars)

	return tempDir
}

func writeVarsFile(t *testing.T, dir string, vars map[string]any) {
	var content string
	for k, v := range vars {
		switch val := v.(type) {
		case string:
			content += fmt.Sprintf("%s = %q\n", k, val)
		case map[string]string:
			content += fmt.Sprintf("%s = {\n", k)
			for mk, mv := range val {
				content += fmt.Sprintf("  %s = %q\n", mk, mv)
			}
			content += "}\n"
		case nil:
			content += fmt.Sprintf("%s = {}\n", k)
		default:
			content += fmt.Sprintf("%s = %v\n", k, val)
		}
	}

	varsPath := filepath.Join(dir, "terraform.tfvars")
	err := os.WriteFile(varsPath, []byte(content), 0644)
	if err != nil {
		t.Fatalf("failed to write tfvars file: %v", err)
	}
}

func copyTerraformFiles(t *testing.T, src, dst string) {
	entries, err := os.ReadDir(src)
	if err != nil {
		t.Fatalf("failed to read source directory: %v", err)
	}

	for _, entry := range entries {
		if entry.IsDir() || filepath.Ext(entry.Name()) != ".tf" {
			continue
		}

		srcPath := filepath.Join(src, entry.Name())
		dstPath := filepath.Join(dst, entry.Name())

		content, err := os.ReadFile(srcPath)
		if err != nil {
			t.Fatalf("failed to read file %s: %v", srcPath, err)
		}

		err = os.WriteFile(dstPath, content, 0644)
		if err != nil {
			t.Fatalf("failed to write file %s: %v", dstPath, err)
		}
	}
}

func TestManagedIdentity_ValidInputs(t *testing.T) {
	t.Parallel()

	testCases := []struct {
		name    string
		uaiName string
		tags    map[string]string
	}{
		{
			name:    "standard_name",
			uaiName: "mi-test-identity",
			tags:    map[string]string{"environment": "test"},
		},
		{
			name:    "minimum_length_name",
			uaiName: "abc",
			tags:    nil,
		},
		{
			name:    "name_with_underscores",
			uaiName: "mi_test_identity",
			tags:    map[string]string{},
		},
		{
			name:    "name_with_mixed_separators",
			uaiName: "mi-test_identity-01",
			tags:    map[string]string{"team": "platform", "cost_center": "12345"},
		},
	}

	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			vars := map[string]any{
				"resource_group_name": "rg-test",
				"location":            "uksouth",
				"uai_name":            tc.uaiName,
				"tags":                tc.tags,
			}
			tempDir := setupTestModule(t, vars)

			terraformOptions := &terraform.Options{
				TerraformDir: tempDir,
				NoColor:      true,
			}

			_, err := terraform.InitAndValidateE(t, terraformOptions)
			assert.NoError(t, err, "Module should validate successfully with valid inputs")
		})
	}
}

// Variable validation rules are only evaluated during 'plan' or 'apply', not 'validate'.
func TestManagedIdentity_InvalidName(t *testing.T) {
	t.Parallel()

	testCases := []struct {
		name        string
		uaiName     string
		description string
	}{
		{
			name:        "too_short_one_char",
			uaiName:     "a",
			description: "single character should be rejected",
		},
		{
			name:        "too_short_two_chars",
			uaiName:     "ab",
			description: "two characters should be rejected",
		},
		{
			name:        "starts_with_hyphen",
			uaiName:     "-mi-identity",
			description: "name starting with hyphen should be rejected",
		},
		{
			name:        "starts_with_underscore",
			uaiName:     "_mi-identity",
			description: "name starting with underscore should be rejected",
		},
		{
			name:        "contains_invalid_chars",
			uaiName:     "mi.test.identity",
			description: "name containing dots should be rejected",
		},
	}

	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			vars := map[string]any{
				"resource_group_name": "rg-test",
				"location":            "uksouth",
				"uai_name":            tc.uaiName,
			}
			tempDir := setupTestModule(t, vars)

			terraformOptions := &terraform.Options{
				TerraformDir: tempDir,
				NoColor:      true,
			}

			_, err := terraform.InitAndPlanE(t, terraformOptions)

			assert.Error(t, err, tc.description)
			if err != nil {
				assert.Contains(t, err.Error(), "User-Assigned Managed Identity name",
					"Error message should mention the identity name validation")
			}
		})
	}
}
