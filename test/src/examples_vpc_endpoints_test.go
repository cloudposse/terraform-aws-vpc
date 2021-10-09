package test

import (
	"github.com/gruntwork-io/terratest/modules/terraform"
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

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../examples/vpc-endpoints",
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
	expectedVpcCidr := "172.17.0.0/16"
	assert.Equal(t, expectedVpcCidr, strings.Trim(vpcCidr, "\""))

	// Verify we're getting back the private Subnet CIDR Blocks we expect
	privateSubnetCidrs := terraform.OutputList(t, terraformOptions, "private_subnet_cidrs")
	expectedPrivateSubnetCidrs := []string{"172.17.0.0/19", "172.17.32.0/19"}
	assert.Equal(t, expectedPrivateSubnetCidrs, privateSubnetCidrs)

	// Verify we're getting back the public Subnet CIDR Blocks we expect
	publicSubnetCidrs := terraform.OutputList(t, terraformOptions, "public_subnet_cidrs")
	expectedPublicSubnetCidrs := []string{"172.17.96.0/19", "172.17.128.0/19"}
	assert.Equal(t, expectedPublicSubnetCidrs, publicSubnetCidrs)

    // Get VPC ID for VPC Endpoint validation
	vpcId := terraform.Output(t, terraformOptions, "vpc_id")

	// Validate created Gateway VPC Endpoints
	gatewayVpcEndpoints := []VpcEndpoint{}
	terraform.OutputStruct(t, terraformOptions, "gateway_vpc_endpoints", &gatewayVpcEndpoints)
	assert.Equal(t, "com.amazonaws.us-east-2.dynamodb", gatewayVpcEndpoints[0].ServiceName)
	assert.Equal(t, "Gateway", gatewayVpcEndpoints[0].VpcEndpointType)
	assert.Equal(t, vpcId, gatewayVpcEndpoints[0].VpcID)
	assert.Equal(t, "com.amazonaws.us-east-2.s3", gatewayVpcEndpoints[1].ServiceName)
	assert.Equal(t, "Gateway", gatewayVpcEndpoints[1].VpcEndpointType)
	assert.Equal(t, vpcId, gatewayVpcEndpoints[1].VpcID)

	// Validate created Interface VPC Endpoints
	interfaceVpcEndpoints := []VpcEndpoint{}
	terraform.OutputStruct(t, terraformOptions, "interface_vpc_endpoints", &interfaceVpcEndpoints)
	assert.Equal(t, "com.amazonaws.us-east-2.ec2", interfaceVpcEndpoints[0].ServiceName)
	assert.Equal(t, "Interface", interfaceVpcEndpoints[0].VpcEndpointType)
	assert.Equal(t, vpcId, interfaceVpcEndpoints[0].VpcID)
	assert.Equal(t, interfaceVpcEndpoints[0].PrivateDNSEnabled, true)
	foundEC2PrivateDNSEntry := false
	for _, entry := range interfaceVpcEndpoints[0].DNSEntry {
	    if entry["dns_name"] == "ec2.us-east-2.amazonaws.com" && !foundEC2PrivateDNSEntry {
	        foundEC2PrivateDNSEntry = true
	    }
	}
	assert.Equal(t, foundEC2PrivateDNSEntry, true)

	assert.Equal(t, "com.amazonaws.us-east-2.kinesis-streams", interfaceVpcEndpoints[1].ServiceName)
	assert.Equal(t, "Interface", interfaceVpcEndpoints[1].VpcEndpointType)
	assert.Equal(t, vpcId, interfaceVpcEndpoints[1].VpcID)
	assert.Equal(t, interfaceVpcEndpoints[1].PrivateDNSEnabled, false)
	foundKinesisStreamsPrivateDNSEntry := false
	for _, entry := range interfaceVpcEndpoints[0].DNSEntry {
	    if entry["dns_name"] == "kinesis-streams.us-east-2.amazonaws.com" && !foundKinesisStreamsPrivateDNSEntry {
	        foundKinesisStreamsPrivateDNSEntry = true
	    }
	}
	assert.Equal(t, foundKinesisStreamsPrivateDNSEntry, false)

}
