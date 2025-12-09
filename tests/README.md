# Tests Directory

This directory contains the automated test suite for this module. Tests are implemented using [Terratest](https://terratest.gruntwork.io/) and the Launch Common Automation Framework (LCAF) testing library.

## Directory Structure

```text
tests/
├── README.md                          # This file
├── post_deploy_functional/            # Full lifecycle tests (deploy, test, destroy)
│   ├── README.md
│   └── main_test.go
├── post_deploy_functional_readonly/   # Read-only tests (no deploy/destroy)
│   ├── README.md
│   └── main_test.go
└── testimpl/                          # Shared test implementation
    ├── README.md
    ├── test_impl.go                   # Test logic and assertions
    └── types.go                       # Test configuration types
```

## Test Types

### Post-Deploy Functional Read-Only Tests (Plan-Only)

Located in `post_deploy_functional_readonly/`, these tests run **FIRST** and:

- ✅ Run `terraform plan` only (no AWS deployment)
- ✅ Validate Terraform configuration syntax
- ✅ Verify plan includes expected resources
- ✅ Check outputs are defined correctly
- ✅ Fast feedback without AWS API calls or costs
- ✅ Safe to run in any environment

### Post-Deploy Functional Tests (Full Deployment)

Located in `post_deploy_functional/`, these tests run **SECOND** and:

- ✅ Deploy the Terraform examples to AWS
- ✅ Validate resources via AWS SDK API calls
- ✅ Verify resource properties match configuration
- ✅ Confirm outputs reflect actual AWS state
- ✅ Destroy resources after testing
- ✅ Require AWS credentials and permissions

### Test Implementation

Located in `testimpl/`, this package contains:

- Shared test logic and assertion functions
- Plan-only validation for readonly tests
- AWS SDK integration for full functional tests
- Reusable test utilities
- Configuration type definitions

## Running Tests

### ⚠️ Important: Run from Repository Root

**Do NOT run tests from this directory.** Always execute tests from the repository root:

```bash
# Correct - run from repository root
cd /workspace
go test -v ./tests/post_deploy_functional/...

# Incorrect - do not run from tests directory
cd /workspace/tests
go test -v ./post_deploy_functional/...  # ❌ Wrong
```

### Prerequisites

1. **AWS Credentials**: Configure AWS credentials with permissions to create/delete EFS resources

   ```bash
   export AWS_REGION=us-west-2
   export AWS_ACCESS_KEY_ID=your_access_key
   export AWS_SECRET_ACCESS_KEY=your_secret_key
   ```

2. **Go Installation**: Go 1.24 or later

   ```bash
   go version
   ```

3. **Dependencies**: Install Go modules

   ```bash
   cd /workspace
   go mod download
   ```

### Running All Tests

```bash
# From repository root - recommended approach
cd /workspace
make test

# This will automatically:
# 1. Run readonly (plan-only) tests FIRST
# 2. Run functional (deployment) tests SECOND
```

### Running Specific Test Suites

```bash
# Run ONLY plan-only tests (no AWS deployment)
go test -v ./tests/post_deploy_functional_readonly

# Run ONLY full functional tests (requires AWS credentials)
go test -v ./tests/post_deploy_functional

# Run specific test function
go test -v ./tests/post_deploy_functional -run TestEFSAccessPointModule
go test -v ./tests/post_deploy_functional_readonly -run TestEFSAccessPointModulePlanOnly
```

### Using Make Targets

```bash
# Run readonly tests only (fast, no AWS)
make go/readonly_test

# Run all tests (readonly first, then functional)
make go/test

# Run with custom timeout
GO_TEST_TIMEOUT=1h make go/test
```

### Test Environment Variables

Control test behavior with environment variables:

```bash
# Skip teardown (leave resources for inspection)
export SKIP_teardown_test_simple=true
go test -v ./tests/post_deploy_functional/...

# Skip setup (use existing infrastructure)
export SKIP_setup_test_simple=true
go test -v ./tests/post_deploy_functional/...

# Disable test parallelization
export DISABLE_PARALLEL=true
go test -v ./tests/post_deploy_functional/...
```

## Test Coverage

### Plan-Only Tests (Readonly)

- ✅ Terraform configuration is valid
- ✅ Plan includes aws_efs_access_point resources
- ✅ Required outputs are defined (access_point_id, access_point_arn, file_system_id)
- ✅ POSIX user configuration structure (if configured)
- ✅ Root directory configuration structure (if configured)

### Full Functional Tests (Deployment)

- ✅ EFS Access Point exists in AWS (verified via AWS SDK)
- ✅ Access Point ID format is correct (fsap-*)
- ✅ Access Point ARN format is valid
- ✅ File system association is correct
- ✅ POSIX user settings match configuration (UID, GID, secondary GIDs)
- ✅ Root directory path and creation info match
- ✅ All Terraform outputs match actual AWS resource properties

## Test Execution Flow

### Readonly Tests (Plan-Only)

```text
┌─────────────────────────────────────────────────────────────┐
│ 1. Initialize Phase                                         │
│    • Initialize Terraform                                   │
│    • Read test.tfvars configuration                         │
│    • No AWS resources created                               │
├─────────────────────────────────────────────────────────────┤
│ 2. Plan Phase                                               │
│    • Run terraform plan                                     │
│    • Generate plan JSON                                     │
│    • No changes applied to AWS                              │
├─────────────────────────────────────────────────────────────┤
│ 3. Validation Phase                                         │
│    • Validate plan structure                                │
│    • Check resource definitions                             │
│    • Verify output definitions                              │
│    • Validate configuration values                          │
└─────────────────────────────────────────────────────────────┘
```

### Functional Tests (Full Deployment)

```text
┌─────────────────────────────────────────────────────────────┐
│ 1. Setup Phase                                              │
│    • Initialize Terraform                                   │
│    • Read test.tfvars configuration                         │
│    • Run terraform apply (deploys to AWS)                   │
└────────────────────────────┬────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────┐
│ 2. Test Phase                                               │
│    • Retrieve Terraform outputs                             │
│    • Query AWS API for resource details                     │
│    • Run assertion tests                                    │
└────────────────────────────┬────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────┐
│ 3. Teardown Phase                                           │
│    • Run terraform destroy                                  │
│    • Clean up test resources                                │
│    • Verify resources are deleted                           │
└─────────────────────────────────────────────────────────────┘
```

## Troubleshooting

### Common Issues

#### Tests fail with "timeout"

- Resources can take time to create/delete
- Tests run to completion naturally without timeout flags
- If a test hangs, cancel it manually (Ctrl+C)

#### Tests fail with "permission denied"

- Verify AWS credentials are configured
- Ensure IAM permissions include required actions

#### Tests fail with "resource already exists"

- Change `creation_token` in test.tfvars to a unique value
- Clean up existing resources manually
- Check for orphaned resources in AWS Console

#### Tests fail but resources remain

- Set `SKIP_teardown_test_simple=true` to debug
- Manually destroy with: `cd examples/simple && terraform destroy`
- Check AWS Console for lingering resources

### Debug Mode

Enable detailed test output:

```bash
# Maximum verbosity
TF_LOG=DEBUG go test -v ./tests/post_deploy_functional/...

# Show Terraform output
go test -v ./tests/post_deploy_functional/... 2>&1 | tee test.log
```

## Adding New Tests

To add additional test coverage:

1. **Add test functions** to `testimpl/test_impl.go`

   ```go
   func testNewFeature(t *testing.T, awsFileSystem *types.FileSystemDescription) {
       // Your assertions here
   }
   ```

2. **Call from TestComposableComplete** in `testimpl/test_impl.go`

   ```go
   t.Run("TestNewFeature", func(t *testing.T) {
       testNewFeature(t, &awsFileSystem)
   })
   ```

3. **Run tests** to verify

   ```bash
   go test -v ./tests/post_deploy_functional/...
   ```

## Best Practices

1. ✅ Always run tests from repository root
2. ✅ Use unique `creation_token` values to avoid conflicts
3. ✅ Let tests run to completion naturally (no timeout flags)
4. ✅ Clean up resources after testing
5. ✅ Use environment variables to control test behavior
6. ✅ Review test output for failures and warnings
7. ✅ Verify resources are deleted after teardown

## Continuous Integration

These tests are designed to run in CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
- name: Run Tests
  run: |
    cd /workspace
    go test -v ./tests/post_deploy_functional/...
  env:
    AWS_REGION: us-west-2
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

## Related Documentation

- [Terratest Documentation](https://terratest.gruntwork.io/)
- [LCAF Testing Library](https://github.com/launchbynttdata/lcaf-component-terratest)
- [Root README](../README.md)
