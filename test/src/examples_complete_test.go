package test

import (
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"path/filepath"
	"strings"
	"testing"
)

// Test the Terraform module in examples/complete using Terratest.
func TestExamplesComplete(t *testing.T) {
	// to use t.Parallel() you need to use test_structure.CopyTerraformFolderToTemp
	// but that leaves a copy of the whole repo laying around in /tmp
	// t.Parallel()

	attributes := []string{random.UniqueId()}
	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/complete"
	varFiles := []string{"fixtures.us-east-2.tfvars"}

/*	testFolder := test_structure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)
    // In some cases, CopyTerraformFolderToTemp does not actually copy the files,
    // so before deleting the folder, check that it is not actually the source folder.
	if testFolder != filepath.Join(rootFolder, terraformFolderRelativeToRoot) {
		defer os.RemoveAll(testFolder)
	}
*/
	testFolder := filepath.Join(rootFolder, terraformFolderRelativeToRoot)

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: testFolder,
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: varFiles,
		Vars: map[string]interface{}{
			"attributes": attributes,
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Verify we're getting back the VPC CIDR Block we expect
	vpcCidr := terraform.Output(t, terraformOptions, "vpc_cidr")
	expectedVpcCidr := "172.16.0.0/16"
	assert.Equal(t, expectedVpcCidr, strings.Trim(vpcCidr, "\""))

	// Verify we're getting back the public Subnet CIDR Blocks we expect
	privateSubnetCidrs := terraform.OutputList(t, terraformOptions, "private_subnet_cidrs")
	expectedPrivateSubnetCidrs := []string{"172.16.0.0/19", "172.16.32.0/19"}
	assert.Equal(t, expectedPrivateSubnetCidrs, privateSubnetCidrs)

	// Verify we're getting back the private Subnet CIDR Blocks we expect
	publicSubnetCidrs := terraform.OutputList(t, terraformOptions, "public_subnet_cidrs")
	expectedPublicSubnetCidrs := []string{"172.16.96.0/19", "172.16.128.0/19"}
	assert.Equal(t, expectedPublicSubnetCidrs, publicSubnetCidrs)
}
