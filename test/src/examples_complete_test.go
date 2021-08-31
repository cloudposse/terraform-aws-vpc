package test

import (
	"testing"
	"strings"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// Test the Terraform module in examples/complete using Terratest.
func TestExamplesComplete(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../examples/complete",
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: []string{"fixtures.us-east-2.tfvars"},
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
