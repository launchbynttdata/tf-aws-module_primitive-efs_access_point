# Complete Example (With Generated Naming)

This example demonstrates a comprehensive configuration of the `tf-aws-module_primitive-efs_access_point` module, showcasing all available features with automatic resource naming and advanced access point configuration.

## Features

- Creates an EFS file system with customizable encryption, performance, and throughput settings
- Creates an EFS access point with POSIX user enforcement (UID: 1000, GID: 1000)
- Configures root directory with creation info (owner and permissions)
- Automatic resource naming using the launch naming module
- Lifecycle policy configuration support
- Protection configuration support
- Demonstrates full tagging strategy
- Region-aware naming: derives region abbreviation from AWS region

## Architecture

This example creates:

1. **EFS File System**: Using the `aws_efs_file_system` resource with full customization
2. **EFS Access Point**: Using the `tf-aws-module_primitive-efs_access_point` module with POSIX user and root directory enforcement
3. **Automatic Naming**: Uses the launch naming convention module to generate consistent resource names
4. **Advanced Features**: Demonstrates optional lifecycle policies and protection settings

## Usage

### Prerequisites

Set the required naming and region variables in your `test.tfvars` or via command line:

```bash
terraform init
terraform plan -var-file=test.tfvars
terraform apply -var-file=test.tfvars
terraform destroy -var-file=test.tfvars
```

### Required Variables

- `aws_region`: The AWS region where resources will be deployed (e.g., "us-east-1")
- `naming_region`: AWS region abbreviation without hyphens (e.g., "useast1") - used by the naming module
- `naming_logical_product_family`: Product family name for naming (default: "launch")
- `naming_logical_product_service`: Product service name for naming (default: "efs")
- `naming_class_env`: Environment class for naming (e.g., "dev", "qa", "prod")
- `naming_instance_env`: Instance environment number for uniqueness (default: 1 for complete example)
- `naming_instance_resource`: Instance resource identifier (default: "001")

### Optional Variables

**EFS File System Configuration** (with `efs_fs_` prefix):

- `efs_fs_encrypted`: Enable encryption (default: true)
- `efs_fs_kms_key_id`: Custom KMS key for encryption (default: AWS managed key)
- `efs_fs_performance_mode`: File system performance mode (default: "generalPurpose")
- `efs_fs_throughput_mode`: Throughput mode (default: "bursting")
- `efs_fs_lifecycle_policy`: Lifecycle policy configuration for cost optimization
- `efs_fs_protection`: Protection configuration for data protection
- `efs_fs_name`: Optional name for the EFS file system
- `efs_fs_creation_token`: Optional creation token for the EFS file system

**EFS Access Point Configuration** (no prefix):

- `name`: Name for the EFS access point (required for main module), This example uses the automatically generated naming from the terraform.registry.launch.nttdata.com/module_library/resource_name/launch module
- `posix_user`: POSIX user configuration (UID/GID) - default: null
- `root_directory`: Root directory path and creation info - default: null
- `tags`: Additional resource tags

## Resources Created

- 1 EFS file system (encrypted with customizable performance settings)
- 1 EFS access point with POSIX user enforced (UID: 1000, GID: 1000)
- Root directory enforced at `/data` with owner enforcement (UID: 1000, GID: 1000, permissions: 755)

## Region Abbreviation

The example automatically derives the region abbreviation from the `aws_region` variable:

- Removes hyphens from the AWS region name
- Example transformations:
  - `us-east-1` → `useast1`
  - `us-west-2` → `uswest2`
  - `eu-west-1` → `euwest1`

## Testing

To test this example:

```bash
cd examples/complete
terraform init

# Validate configuration
terraform validate

# Plan the deployment
terraform plan -var-file=test.tfvars

# Apply the configuration
terraform apply -var-file=test.tfvars

# Verify outputs
terraform output

# Cleanup - destroy all resources
terraform destroy -var-file=test.tfvars
```

## Example test.tfvars

```hcl
aws_region = "us-east-1"

# Naming convention configuration (with naming_ prefix)
naming_logical_product_family  = "launch"
naming_logical_product_service = "efs"
naming_region                  = "use"
naming_class_env               = "dev"
naming_instance_env            = 1
naming_instance_resource       = "001"

naming_resource_names_map = {
  efs_ap = {
    name       = "ap"
    max_length = 60
  },
  efs_fs = {
    name       = "fs"
    max_length = 255
  }
}

# EFS file system configuration (with efs_fs_ prefix)
efs_fs_encrypted        = true
efs_fs_performance_mode = "generalPurpose"
efs_fs_throughput_mode  = "bursting"

# Access point configuration with POSIX user enforcement (no prefix)
posix_user = {
  uid = 1000
  gid = 1000
}

# Root directory with creation info (no prefix)
root_directory = {
  path = "/data"
  creation_info = {
    owner_uid   = 1000
    owner_gid   = 1000
    permissions = "755"
  }
}

tags = {
  Environment = "dev"
  Example     = "complete"
  Application = "efs-access-point"
}
```

## Security Considerations

- **POSIX User Enforcement**: The access point enforces that all file operations use UID: 1000, GID: 1000, preventing privilege escalation
- **Root Directory Enforcement**: Clients can only access files within the `/data` directory tree
- **File Permissions**: The root directory is created with 755 permissions (readable/executable for all, writable only by owner)
- **Access Control**: Combine with appropriate IAM policies and security group rules

## Notes

- This is a feature-complete configuration that demonstrates all capabilities of the EFS access point module
- The access point enforces POSIX user identity for all file operations
- The root directory configuration enforces a specific path and directory permissions
- All resources are tagged with Environment, Example, and Application tags for easy identification and cost allocation
- The `aws_region` and `region` variables are required and must be explicitly provided
- The `instance_env` is set to 1 for the complete example, ensuring unique names when compared to the simple example (instance_env = 0)
- This example is ideal for production-like scenarios with strict access control requirements

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.100 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_names"></a> [resource\_names](#module\_resource\_names) | terraform.registry.launch.nttdata.com/module_library/resource_name/launch | ~> 2.0 |
| <a name="module_efs_access_point"></a> [efs\_access\_point](#module\_efs\_access\_point) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_efs_file_system.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | (Required) The location where the resource will be created. Must not have spaces<br/>    For example, us-east-1, us-west-2, eu-west-1, etc. | `string` | n/a | yes |
| <a name="input_naming_logical_product_family"></a> [naming\_logical\_product\_family](#input\_naming\_logical\_product\_family) | (Required) Name of the product family for which the resource is created.<br/>    Example: org\_name, department\_name. | `string` | `"launch"` | no |
| <a name="input_naming_logical_product_service"></a> [naming\_logical\_product\_service](#input\_naming\_logical\_product\_service) | (Required) Name of the product service for which the resource is created.<br/>    For example, backend, frontend, middleware etc. | `string` | `"backend"` | no |
| <a name="input_naming_instance_resource"></a> [naming\_instance\_resource](#input\_naming\_instance\_resource) | Number that represents the instance of the resource. | `number` | `0` | no |
| <a name="input_naming_instance_env"></a> [naming\_instance\_env](#input\_naming\_instance\_env) | Number that represents the instance of the environment. | `number` | `0` | no |
| <a name="input_naming_class_env"></a> [naming\_class\_env](#input\_naming\_class\_env) | (Required) Environment where resource is going to be deployed. For example. dev, qa, uat | `string` | `"dev"` | no |
| <a name="input_naming_resource_names_map"></a> [naming\_resource\_names\_map](#input\_naming\_resource\_names\_map) | A map of key to resource\_name that will be used by tf-launch-module\_library-resource\_name to generate resource names | <pre>map(object(<br/>    {<br/>      name       = string<br/>      max_length = optional(number, 60)<br/>    }<br/>  ))</pre> | `{}` | no |
| <a name="input_efs_fs_creation_token"></a> [efs\_fs\_creation\_token](#input\_efs\_fs\_creation\_token) | A unique name used as reference when creating the EFS. If null, will use generated name from resource\_names module | `string` | `null` | no |
| <a name="input_efs_fs_encrypted"></a> [efs\_fs\_encrypted](#input\_efs\_fs\_encrypted) | Enable encryption at rest for the EFS file system. | `bool` | `true` | no |
| <a name="input_efs_fs_kms_key_id"></a> [efs\_fs\_kms\_key\_id](#input\_efs\_fs\_kms\_key\_id) | The ARN for the KMS encryption key to be used to encrypt the filesystem. | `string` | `null` | no |
| <a name="input_efs_fs_performance_mode"></a> [efs\_fs\_performance\_mode](#input\_efs\_fs\_performance\_mode) | The file system performance mode. Valid values: generalPurpose, maxIO. | `string` | `"generalPurpose"` | no |
| <a name="input_efs_fs_throughput_mode"></a> [efs\_fs\_throughput\_mode](#input\_efs\_fs\_throughput\_mode) | Throughput mode for the file system. Valid values: bursting, provisioned. | `string` | `"bursting"` | no |
| <a name="input_efs_fs_lifecycle_policy"></a> [efs\_fs\_lifecycle\_policy](#input\_efs\_fs\_lifecycle\_policy) | A lifecycle\_policy block as defined below. | <pre>object({<br/>    transition_to_ia                    = optional(string)<br/>    transition_to_primary_storage_class = optional(string)<br/>    transition_to_archive               = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_efs_fs_protection"></a> [efs\_fs\_protection](#input\_efs\_fs\_protection) | A protection block as defined below. | <pre>object({<br/>    replication_overwrite = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_efs_fs_name"></a> [efs\_fs\_name](#input\_efs\_fs\_name) | Optional name for the EFS file system. If provided, will be added as a 'Name' tag. If null, will use generated name from resource\_names module | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Optional name for the EFS access point. If provided, will be added as a 'Name' tag. | `string` | `null` | no |
| <a name="input_posix_user"></a> [posix\_user](#input\_posix\_user) | POSIX user configuration for the access point | <pre>object({<br/>    uid            = number<br/>    gid            = number<br/>    secondary_gids = optional(list(number))<br/>  })</pre> | `null` | no |
| <a name="input_root_directory"></a> [root\_directory](#input\_root\_directory) | Root directory configuration for the access point | <pre>object({<br/>    path = string<br/>    creation_info = optional(object({<br/>      owner_uid   = number<br/>      owner_gid   = number<br/>      permissions = string<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resources | `map(string)` | <pre>{<br/>  "Environment": "dev",<br/>  "Example": "complete"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_file_system_id"></a> [file\_system\_id](#output\_file\_system\_id) | The ID of the EFS file system |
| <a name="output_file_system_arn"></a> [file\_system\_arn](#output\_file\_system\_arn) | The ARN of the EFS file system |
| <a name="output_access_point_id"></a> [access\_point\_id](#output\_access\_point\_id) | The ID of the EFS access point |
| <a name="output_access_point_arn"></a> [access\_point\_arn](#output\_access\_point\_arn) | The ARN of the EFS access point |
| <a name="output_file_system_name"></a> [file\_system\_name](#output\_file\_system\_name) | The Name tag of the EFS file system (if set) |
| <a name="output_access_point_name"></a> [access\_point\_name](#output\_access\_point\_name) | The Name tag of the EFS access point (if set) |
| <a name="output_access_point_owner_id"></a> [access\_point\_owner\_id](#output\_access\_point\_owner\_id) | The AWS account ID that owns the access point resource |
| <a name="output_access_point_posix_user"></a> [access\_point\_posix\_user](#output\_access\_point\_posix\_user) | The POSIX user identity configuration including secondary GIDs |
| <a name="output_access_point_root_directory"></a> [access\_point\_root\_directory](#output\_access\_point\_root\_directory) | The root directory configuration including creation info |
| <a name="output_access_point_tags"></a> [access\_point\_tags](#output\_access\_point\_tags) | Tags assigned to the access point |
<!-- END_TF_DOCS -->
