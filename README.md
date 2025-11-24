# tf-aws-module_primitive-efs_access_point

A Terraform primitive module that wraps the `aws_efs_access_point` resource, providing a consistent and validated interface for managing EFS Access Points.

## What is a Primitive Module?

A **primitive module** is a thin, focused Terraform wrapper around a single AWS resource type. Primitive modules:

- Wrap a **single AWS resource** (e.g., `aws_efs_access_point`)
- Provide sensible defaults while maintaining full configurability
- Include comprehensive validation rules
- Follow consistent patterns for inputs, outputs, and tagging
- Include automated testing using Terratest
- Serve as building blocks for higher-level composite modules

## Overview

This module creates an **EFS Access Point** that enforces a user identity and root directory for clients accessing an EFS file system. Access points simplify access management by:

- Enforcing a POSIX user identity for all connections
- Enforcing a root directory for the file system
- Enabling access control at the file system level
- Improving security through identity isolation

### Key Features

- **POSIX User Enforcement**: Optionally enforce a specific UID/GID for all file access
- **Root Directory Configuration**: Optionally enforce a specific directory as the root path
- **Creation Info**: Optionally configure owner and permissions for the root directory
- **Comprehensive Tagging**: Full support for resource tagging
- **Flexible Configuration**: All options are optional, supporting both simple and complex scenarios
- **Validation**: Input validation ensures correct configuration

## Usage

### Simple Example

Create a basic EFS access point with minimal configuration:

```hcl
module "efs_access_point" {
  source = "git::https://github.com/launchbynttdata/tf-aws-module_primitive-efs_access_point.git?ref=main"

  efs_file_system_id = aws_efs_file_system.example.id

  tags = {
    Environment = "production"
    Application = "myapp"
  }
}
```

### Complete Example

Create an EFS access point with POSIX user and root directory enforcement:

```hcl
module "efs_access_point" {
  source = "git::https://github.com/launchbynttdata/tf-aws-module_primitive-efs_access_point.git?ref=main"

  efs_file_system_id = aws_efs_file_system.example.id

  posix_user = {
    uid = 1000
    gid = 1000
  }

  root_directory = {
    path = "/app-data"
    creation_info = {
      owner_uid   = 1000
      owner_gid   = 1000
      permissions = "755"
    }
  }

  tags = {
    Environment = "production"
    Application = "myapp"
  }
}
```

## Module Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `efs_file_system_id` | The ID of the EFS file system | `string` | n/a | yes |
| `posix_user` | POSIX user configuration for the access point | `object({ uid = number, gid = number })` | `null` | no |
| `root_directory` | Root directory configuration for the access point | `object({ path = string, creation_info = optional(...) })` | `null` | no |
| `name` | Name tag for the access point resource | `string` | `null` | no |
| `tags` | A map of tags to assign to the resource | `map(string)` | `{}` | no |

### Input Details

#### `efs_file_system_id`
- **Type**: `string`
- **Required**: Yes
- **Description**: The ID of the EFS file system to which this access point will be attached

#### `posix_user`
- **Type**: `object({ uid = number, gid = number })`
- **Default**: `null`
- **Description**: POSIX user configuration. When set, enforces that all file system requests use the specified UID and GID
- **Fields**:
  - `uid`: The numeric user ID (UID)
  - `gid`: The numeric group ID (GID)

#### `root_directory`
- **Type**: `object({ path = string, creation_info = optional(object({ owner_uid = number, owner_gid = number, permissions = string })) })`
- **Default**: `null`
- **Description**: Root directory configuration. When set, specifies a directory within the file system to serve as the root
- **Fields**:
  - `path`: The absolute path to the directory within the file system (e.g., `/data`)
  - `creation_info` (optional):
    - `owner_uid`: The numeric UID to use for directory ownership
    - `owner_gid`: The numeric GID to use for directory ownership
    - `permissions`: The permission mode in octal format (e.g., `"755"`)

#### `tags`
- **Type**: `map(string)`
- **Default**: `{}`
- **Description**: A map of tags to assign to the access point resource
- **Special Tags**: The module automatically adds a `ManagedBy = "Terraform"` tag

#### `name`
- **Type**: `string`
- **Default**: `null`
- **Description**: Name tag for the access point resource. If provided, will be added as a 'Name' tag.

## Module Outputs

| Name | Description | Type |
|------|-------------|------|
| `access_point_id` | The ID of the EFS access point | `string` |
| `access_point_arn` | The ARN of the EFS access point | `string` |

## Requirements

- **Terraform**: >= 1.7
- **AWS Provider**: >= 5.100

## Examples

### Example 1: Basic Access Point (Minimal Configuration)

```hcl
module "basic_access_point" {
  source = "git::https://github.com/launchbynttdata/tf-aws-module_primitive-efs_access_point.git?ref=main"

  efs_file_system_id = aws_efs_file_system.main.id

  tags = {
    Environment = "dev"
    Name        = "basic-ap"
  }
}
```

### Example 2: Access Point with POSIX User

```hcl
module "app_user_access_point" {
  source = "git::https://github.com/launchbynttdata/tf-aws-module_primitive-efs_access_point.git?ref=main"

  efs_file_system_id = aws_efs_file_system.main.id

  posix_user = {
    uid = 1000
    gid = 1000
  }

  tags = {
    Environment = "prod"
    Name        = "app-user-ap"
  }
}
```

### Example 3: Access Point with Root Directory Enforcement

```hcl
module "restricted_access_point" {
  source = "git::https://github.com/launchbynttdata/tf-aws-module_primitive-efs_access_point.git?ref=main"

  efs_file_system_id = aws_efs_file_system.main.id

  root_directory = {
    path = "/var/app/data"
    creation_info = {
      owner_uid   = 500
      owner_gid   = 500
      permissions = "700"
    }
  }

  tags = {
    Environment = "prod"
    Name        = "restricted-ap"
  }
}
```

### Example 4: Complete Access Point (All Features)

See `examples/complete/` for a full working example that demonstrates all features including file system creation.

### Example 5: Simple Access Point (Quick Start)

See `examples/simple/` for a quick-start example showing minimal configuration.

## Testing

### Prerequisites

- Terraform >= 1.7
- AWS CLI configured with appropriate credentials
- Go 1.23 or later
- `make` command

### Running Tests

```bash
# Run all validation checks including formatting, linting, and Terratest
make check

# Run only Terratest functional tests
cd tests && go test ./...

# Run specific example tests
cd examples/simple && terraform plan -var-file=test.tfvars
cd examples/complete && terraform plan -var-file=test.tfvars
```

## Security Considerations

1. **POSIX User Enforcement**: When `posix_user` is configured, all file operations through the access point will use the specified UID/GID, preventing privilege escalation

2. **Root Directory Enforcement**: When `root_directory` is configured, clients can only access files within the specified directory tree, preventing access to other file system areas

3. **File Permissions**: Set appropriate `permissions` in `creation_info` to control access to the root directory

4. **Access Control**: Combine access points with appropriate IAM policies and security group rules to implement defense-in-depth

## Important Notes

- The EFS file system must exist before creating an access point
- POSIX user IDs should be unique across your access points for clarity
- The root directory path must exist in the file system or be auto-created with the specified `creation_info`
- Access points are useful for multi-tenant scenarios where different users/applications need isolated access
- Consider using access points with Amazon EFS mount helpers for simplified setup

## Documentation

- [AWS EFS Access Points Documentation](https://docs.aws.amazon.com/efs/latest/ug/efs-access-points.html)
- [AWS EFS Best Practices](https://docs.aws.amazon.com/efs/latest/ug/best-practices.html)

## Contributing

Please follow the established patterns in this module when contributing. All contributions should:

- Pass `make check` validation
- Include appropriate examples if adding features
- Update documentation as needed
- Follow the Apache 2.0 license terms

## License

This module is licensed under the Apache License 2.0. See [LICENSE](LICENSE) for details.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.100 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_efs_access_point.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_efs_file_system_id"></a> [efs\_file\_system\_id](#input\_efs\_file\_system\_id) | The ID of the EFS file system | `string` | n/a | yes |
| <a name="input_posix_user"></a> [posix\_user](#input\_posix\_user) | A POSIX user identity block. Enforces a user identity for all file system requests made through the access point. | <pre>object({<br/>    uid            = number<br/>    gid            = number<br/>    secondary_gids = optional(list(number))<br/>  })</pre> | `null` | no |
| <a name="input_root_directory"></a> [root\_directory](#input\_root\_directory) | A root directory block. Specifies the directory on the EFS file system that the access point provides access to. | <pre>object({<br/>    path = string<br/>    creation_info = optional(object({<br/>      owner_uid   = number<br/>      owner_gid   = number<br/>      permissions = string<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name tag for the access point resource. If provided, will be added as a 'Name' tag. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the EFS file system | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_point_id"></a> [access\_point\_id](#output\_access\_point\_id) | The ID of the EFS access point |
| <a name="output_access_point_arn"></a> [access\_point\_arn](#output\_access\_point\_arn) | Amazon Resource Name of the access point |
| <a name="output_file_system_id"></a> [file\_system\_id](#output\_file\_system\_id) | The ID of the EFS file system that the access point applies to |
| <a name="output_owner_id"></a> [owner\_id](#output\_owner\_id) | The AWS account ID that owns the access point resource |
| <a name="output_posix_user"></a> [posix\_user](#output\_posix\_user) | The full POSIX identity, including the user ID, group ID, and secondary group IDs on the access point |
| <a name="output_root_directory"></a> [root\_directory](#output\_root\_directory) | The directory on the EFS file system that the access point exposes as the root directory to NFS clients |
| <a name="output_tags"></a> [tags](#output\_tags) | A map of tags assigned to the access point |
<!-- END_TF_DOCS -->
