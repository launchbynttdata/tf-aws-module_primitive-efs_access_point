// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package testimpl

import (
	"context"
	"regexp"
	"testing"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/efs"
	"github.com/gruntwork-io/terratest/modules/terraform"
	testTypes "github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestPlanOnlyValidation performs validation on terraform plan output without deploying resources
func TestPlanOnlyValidation(t *testing.T, ctx testTypes.TestContext) {
	// Get the plan output in JSON format
	planJSON := terraform.InitAndPlanAndShowWithStructContext(t, context.Background(), ctx.TerratestTerraformOptions())

	t.Run("TestPlanHasResources", func(t *testing.T) {
		testPlanHasResources(t, planJSON)
	})

	t.Run("TestPlanOutputsExist", func(t *testing.T) {
		testPlanOutputsExist(t, planJSON)
	})

	t.Run("TestPlanAccessPointConfiguration", func(t *testing.T) {
		testPlanAccessPointConfiguration(t, planJSON)
	})
}

func testPlanHasResources(t *testing.T, planJSON *terraform.PlanStruct) {
	require.NotNil(t, planJSON, "Plan JSON should not be nil")
	require.NotNil(t, planJSON.ResourceChangesMap, "Resource changes map should not be nil")

	// Check that we have at least one EFS access point resource
	foundAccessPoint := false
	for _, change := range planJSON.ResourceChangesMap {
		if change.Type == "aws_efs_access_point" {
			foundAccessPoint = true
			break
		}
	}

	assert.True(t, foundAccessPoint, "Plan should include at least one aws_efs_access_point resource")
}

func testPlanOutputsExist(t *testing.T, planJSON *terraform.PlanStruct) {
	require.NotNil(t, planJSON, "Plan JSON should not be nil")
	require.NotNil(t, planJSON.RawPlan.OutputChanges, "Output changes should not be nil")

	// Verify expected outputs are defined in the plan
	expectedOutputs := []string{"access_point_id", "access_point_arn", "file_system_id"}
	for _, outputName := range expectedOutputs {
		_, exists := planJSON.RawPlan.OutputChanges[outputName]
		assert.True(t, exists, "Output '%s' should be defined in the plan", outputName)
	}
}

func testPlanAccessPointConfiguration(t *testing.T, planJSON *terraform.PlanStruct) {
	require.NotNil(t, planJSON, "Plan JSON should not be nil")

	// Find the EFS access point resource in the plan
	for _, change := range planJSON.ResourceChangesMap {
		if change.Type == "aws_efs_access_point" && change.Change != nil && change.Change.After != nil {
			// Validate the configuration in the plan
			afterMap, ok := change.Change.After.(map[string]interface{})
			require.True(t, ok, "After state should be a map")

			// Check that file_system_id is set
			_, hasFileSystemID := afterMap["file_system_id"]
			assert.True(t, hasFileSystemID, "Access point should have file_system_id configured")

			// If POSIX user is configured, validate structure
			if posixUser, hasPosixUser := afterMap["posix_user"]; hasPosixUser {
				if posixUserSlice, ok := posixUser.([]interface{}); ok && len(posixUserSlice) > 0 {
					if posixUserMap, ok := posixUserSlice[0].(map[string]interface{}); ok {
						_, hasUID := posixUserMap["uid"]
						_, hasGID := posixUserMap["gid"]
						assert.True(t, hasUID, "POSIX user should have UID configured")
						assert.True(t, hasGID, "POSIX user should have GID configured")
					}
				}
			}

			// If root directory is configured, validate structure
			if rootDir, hasRootDir := afterMap["root_directory"]; hasRootDir {
				if rootDirSlice, ok := rootDir.([]interface{}); ok && len(rootDirSlice) > 0 {
					if rootDirMap, ok := rootDirSlice[0].(map[string]interface{}); ok {
						_, hasPath := rootDirMap["path"]
						assert.True(t, hasPath, "Root directory should have path configured")
					}
				}
			}
		}
	}
}

func TestComposableComplete(t *testing.T, ctx testTypes.TestContext) {
	// Get EFS client to verify access point info
	efsClient := GetAWSEFSClient(t)

	// Get outputs from Terraform
	accessPointID := terraform.OutputContext(t, context.Background(), ctx.TerratestTerraformOptions(), "access_point_id")
	accessPointARN := terraform.OutputContext(t, context.Background(), ctx.TerratestTerraformOptions(), "access_point_arn")
	fileSystemID := terraform.OutputContext(t, context.Background(), ctx.TerratestTerraformOptions(), "file_system_id")

	t.Run("TestAccessPointIdNotEmpty", func(t *testing.T) {
		testAccessPointIdNotEmpty(t, accessPointID)
	})

	t.Run("TestAccessPointArnFormat", func(t *testing.T) {
		testAccessPointArnFormat(t, accessPointARN)
	})

	t.Run("TestAccessPointExists", func(t *testing.T) {
		testAccessPointExists(t, efsClient, accessPointID)
	})

	t.Run("TestAccessPointFileSystemID", func(t *testing.T) {
		testAccessPointFileSystemID(t, efsClient, accessPointID, fileSystemID)
	})

	t.Run("TestAccessPointPOSIXUser", func(t *testing.T) {
		testAccessPointPOSIXUser(t, efsClient, accessPointID)
	})

	t.Run("TestAccessPointRootDirectory", func(t *testing.T) {
		testAccessPointRootDirectory(t, efsClient, accessPointID)
	})
}

func testAccessPointIdNotEmpty(t *testing.T, accessPointID string) {
	assert.NotEmpty(t, accessPointID, "Access Point ID should not be empty")

	// Verify it looks like a valid EFS access point ID (format: fsap-XXXXXXXXXXXXXXXX)
	matched, _ := regexp.MatchString(`^fsap-[a-f0-9]{17}$`, accessPointID)
	assert.True(t, matched, "Access Point ID should match pattern 'fsap-[a-f0-9]{17}'")
}

func testAccessPointArnFormat(t *testing.T, accessPointARN string) {
	assert.NotEmpty(t, accessPointARN, "Access Point ARN should not be empty")

	// Verify it's a valid ARN format
	matched, _ := regexp.MatchString(`^arn:aws:elasticfilesystem:[a-z]{2}-[a-z]+-\d+:\d{12}:access-point/fsap-[a-f0-9]{17}$`, accessPointARN)
	assert.True(t, matched, "Access Point ARN should match EFS ARN pattern")
}

func testAccessPointExists(t *testing.T, efsClient *efs.Client, accessPointID string) {
	// Verify the access point exists in AWS
	input := &efs.DescribeAccessPointsInput{
		AccessPointId: aws.String(accessPointID),
	}

	output, err := efsClient.DescribeAccessPoints(context.TODO(), input)
	require.NoError(t, err, "Failed to describe access point from AWS")
	require.NotNil(t, output, "DescribeAccessPoints output should not be nil")
	require.Greater(t, len(output.AccessPoints), 0, "At least one access point should be returned")

	accessPoint := output.AccessPoints[0]
	assert.Equal(t, accessPointID, *accessPoint.AccessPointId, "Access Point ID should match")
}

func GetAWSEFSClient(t *testing.T) *efs.Client {
	efsClient := efs.NewFromConfig(GetAWSConfig(t))
	return efsClient
}

func GetAWSConfig(t *testing.T) (cfg aws.Config) {
	cfg, err := config.LoadDefaultConfig(context.TODO())
	require.NoErrorf(t, err, "unable to load SDK config, %v", err)
	return cfg
}

func testAccessPointFileSystemID(t *testing.T, efsClient *efs.Client, accessPointID string, expectedFileSystemID string) {
	// Verify the access point is associated with the correct file system
	input := &efs.DescribeAccessPointsInput{
		AccessPointId: aws.String(accessPointID),
	}

	output, err := efsClient.DescribeAccessPoints(context.TODO(), input)
	require.NoError(t, err, "Failed to describe access point from AWS")
	require.Greater(t, len(output.AccessPoints), 0, "At least one access point should be returned")

	accessPoint := output.AccessPoints[0]
	assert.Equal(t, expectedFileSystemID, *accessPoint.FileSystemId, "Access Point should be associated with the correct file system")
}

func testAccessPointPOSIXUser(t *testing.T, efsClient *efs.Client, accessPointID string) {
	// Verify POSIX user configuration is set
	input := &efs.DescribeAccessPointsInput{
		AccessPointId: aws.String(accessPointID),
	}

	output, err := efsClient.DescribeAccessPoints(context.TODO(), input)
	require.NoError(t, err, "Failed to describe access point from AWS")
	require.Greater(t, len(output.AccessPoints), 0, "At least one access point should be returned")

	accessPoint := output.AccessPoints[0]
	// POSIX user configuration may or may not be set depending on the test configuration
	if accessPoint.PosixUser != nil {
		assert.NotNil(t, accessPoint.PosixUser.Uid, "POSIX user UID should be set")
		assert.NotNil(t, accessPoint.PosixUser.Gid, "POSIX user GID should be set")
	}
}

func testAccessPointRootDirectory(t *testing.T, efsClient *efs.Client, accessPointID string) {
	// Verify root directory configuration is set
	input := &efs.DescribeAccessPointsInput{
		AccessPointId: aws.String(accessPointID),
	}

	output, err := efsClient.DescribeAccessPoints(context.TODO(), input)
	require.NoError(t, err, "Failed to describe access point from AWS")
	require.Greater(t, len(output.AccessPoints), 0, "At least one access point should be returned")

	accessPoint := output.AccessPoints[0]
	// Root directory configuration may or may not be set depending on the test configuration
	if accessPoint.RootDirectory != nil {
		assert.NotEmpty(t, *accessPoint.RootDirectory.Path, "Root directory path should not be empty")
	}
}
