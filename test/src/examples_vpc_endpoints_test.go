package test

import (
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"strings"
	"testing"
)

type VpcEndpoint struct {
	S3                  string              `json:"arn"`
	AutoAccept          bool                `json:"auto_accept"`
	CidrBlocks          []string            `json:"cidr_blocks"`
	DNSEntry            []map[string]string `json:"dns_entry"`
	ID                  string              `json:"id"`
	NetworkInterfaceIds []string            `json:"network_interface_ids"`
	OwnerID             string              `json:"owner_id"`
	Policy              string              `json:"policy"`
	PrivateDNSEnabled   bool                `json:"private_dns_enabled"`
	PrefixListID        string              `json:"prefix_list_id"`
	RequesterManaged    bool                `json:"requester_managed"`
	RouteTableIDs       []string            `json:"route_table_ids"`
	SecurityGroupIDs    []string            `json:"security_group_ids"`
	ServiceName         string              `json:"service_name"`
	State               string              `json:"state"`
	SubnetIDs           []string            `json:"subnet_ids"`
	Tags                map[string]string   `json:"tags"`
	Timeouts            interface{}         `json:"timeouts"`
	VpcEndpointType     string              `json:"vpc_endpoint_type"`
	VpcID               string              `json:"vpc_id"`
}

// Test the Terraform module in examples/vpc_endpoints using Terratest.
func TestExamplesVPCEndpoints(t *testing.T) {
	// Be careful with t.Parallel() unless you are using test_structure.CopyTerraformFolderToTemp
	// or else you risk parallel executions clobbering each other's state or
	// not really running in parallel due to state locks. We can do it here
	// because each test is in its own directory.
	t.Parallel()

	randID := strings.ToLower(random.UniqueId())
	attributes := []string{randID}

	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/vpc-endpoints"
	varFiles := []string{"fixtures.us-east-2.tfvars"}

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: tempTestFolder,
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: varFiles,
		Vars: map[string]interface{}{
			"attributes": attributes,
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer cleanup(t, terraformOptions, tempTestFolder)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Verify we're getting back the VPC CIDR Block we expect
	vpcCidr := terraform.Output(t, terraformOptions, "vpc_cidr")
	expectedVpcCidr := "172.17.0.0/16"
	assert.Equal(t, expectedVpcCidr, strings.Trim(vpcCidr, "\""))

	// Verify we're getting back the private Subnet CIDR Blocks we expect
	privateSubnetCidrs := terraform.OutputList(t, terraformOptions, "private_subnet_cidrs")
	expectedPrivateSubnetCidrs := []string{"172.17.0.0/18", "172.17.64.0/18"}
	assert.Equal(t, expectedPrivateSubnetCidrs, privateSubnetCidrs)

	// Verify we're getting back the public Subnet CIDR Blocks we expect
	publicSubnetCidrs := terraform.OutputList(t, terraformOptions, "public_subnet_cidrs")
	assert.Empty(t, publicSubnetCidrs)

	// Get VPC ID for VPC Endpoint validation
	vpcId := terraform.Output(t, terraformOptions, "vpc_id")

	// Validate created Gateway VPC Endpoints
	gatewayVpcEndpoints := map[string]VpcEndpoint{}
	terraform.OutputStruct(t, terraformOptions, "gateway_vpc_endpoints", &gatewayVpcEndpoints)
	assert.Equal(t, "com.amazonaws.us-east-2.dynamodb", gatewayVpcEndpoints["dynamodb"].ServiceName)
	assert.Equal(t, "Gateway", gatewayVpcEndpoints["dynamodb"].VpcEndpointType)
	assert.Equal(t, vpcId, gatewayVpcEndpoints["dynamodb"].VpcID)
	assert.Equal(t, "com.amazonaws.us-east-2.s3", gatewayVpcEndpoints["s3"].ServiceName)
	assert.Equal(t, "Gateway", gatewayVpcEndpoints["s3"].VpcEndpointType)
	assert.Equal(t, vpcId, gatewayVpcEndpoints["s3"].VpcID)

	// Validate created Interface VPC Endpoints
	interfaceVpcEndpoints := map[string]VpcEndpoint{}
	terraform.OutputStruct(t, terraformOptions, "interface_vpc_endpoints", &interfaceVpcEndpoints)
	assert.Equal(t, "com.amazonaws.us-east-2.ec2", interfaceVpcEndpoints["ec2"].ServiceName)
	assert.Equal(t, "Interface", interfaceVpcEndpoints["ec2"].VpcEndpointType)
	assert.Equal(t, vpcId, interfaceVpcEndpoints["ec2"].VpcID)
	assert.Equal(t, true, interfaceVpcEndpoints["ec2"].PrivateDNSEnabled)
	foundEC2PrivateDNSEntry := false
	for _, entry := range interfaceVpcEndpoints["ec2"].DNSEntry {
		if entry["dns_name"] == "ec2.us-east-2.amazonaws.com" && !foundEC2PrivateDNSEntry {
			foundEC2PrivateDNSEntry = true
		}
	}
	assert.Equal(t, true, foundEC2PrivateDNSEntry)

	assert.Equal(t, "com.amazonaws.us-east-2.kinesis-streams", interfaceVpcEndpoints["kinesis-streams"].ServiceName)
	assert.Equal(t, "Interface", interfaceVpcEndpoints["kinesis-streams"].VpcEndpointType)
	assert.Equal(t, vpcId, interfaceVpcEndpoints["kinesis-streams"].VpcID)
	assert.Equal(t, false, interfaceVpcEndpoints["kinesis-streams"].PrivateDNSEnabled)
	foundKinesisStreamsPrivateDNSEntry := false
	for _, entry := range interfaceVpcEndpoints["kinesis-streams"].DNSEntry {
		if entry["dns_name"] == "kinesis-streams.us-east-2.amazonaws.com" && !foundKinesisStreamsPrivateDNSEntry {
			foundKinesisStreamsPrivateDNSEntry = true
		}
	}
	assert.Equal(t, false, foundKinesisStreamsPrivateDNSEntry)

}
