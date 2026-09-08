# tf-aws-module_primitive-efs_access_point

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![License: CC BY-NC-ND 4.0](https://img.shields.io/badge/License-CC_BY--NC--ND_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-nd/4.0/)

## Overview

This module wraps the [`aws_efs_access_point`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point) resource. It creates an EFS access point that enforces a user identity and root directory for clients accessing an EFS file system.

Access points simplify access management by:

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

```hcl
module "efs_access_point" {
  source = "git::https://github.com/launchbynttdata/tf-aws-module_primitive-efs_access_point.git?ref=main"

  efs_file_system_id = aws_efs_file_system.example.id
  name               = "my-access-point"

  tags = {
    Environment = "production"
    Application = "myapp"
  }
}
```

### Complete Example

```hcl
module "efs_access_point" {
  source = "git::https://github.com/launchbynttdata/tf-aws-module_primitive-efs_access_point.git?ref=main"

  efs_file_system_id = aws_efs_file_system.example.id
  name               = "my-access-point"

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

## Examples

See [examples/complete](./examples/complete) and [examples/complete-fixed-naming](./examples/complete-fixed-naming).

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
| <a name="input_posix_user"></a> [posix\_user](#input\_posix\_user) | A POSIX user identity block. Enforces a user identity for all file system requests made through the access point. | <pre>object({<br/>    uid            = number<br/>    gid            = number<br/>    secondary_gids = optional(list(number), [])<br/>  })</pre> | `null` | no |
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

## Module Development

### Pre-Requisites

The following commands should be available on your system:

- `asdf` or `mise`
- `make`
- `python3` (for pre-commit)

Additionally, your `git` user and email must be configured. Run the `make configure` command from the root of the repository to ensure that you meet these requirements.

### Pre-Commit hooks

The [.pre-commit-config.yaml](.pre-commit-config.yaml) file defines certain `pre-commit` hooks that are relevant to Terraform and Golang, as well as some common linting tasks. These will be configured for you when you run `make configure`.

### Local Validation

You should validate the changes you make to any module locally, prior to pushing your changes in a branch to GitHub.

1. Ensure that you have run `make configure` successfully.

2. Ensure you are signed into the appropriate cloud provider (e.g. AWS or Azure) for the module under test in your current console session.

3. Run the Terraform and Golang linters with the following command:

```
make lint
```

4. Once you have satisfied the linters, the following command will build example infrastructure in your configured cloud, run the tests, and then tear down the infrastructure it created:

```
make test
```

The pre-commit validations, as well as the `make lint` and `make test` targets, will all be performed in CI. Running these validations locally prior to opening a PR helps ensure a smooth review and merge process.

### Review & Merge Process

Once your change has been tested locally and your branch pushed up, open a new Pull Request for your branch to the default (main) branch of this repository.

The title of your Pull Request will determine the version bump for this change, and the title must be in [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/#specification) format in order to merge. A breaking change will trigger a major version bump, a feature will trigger a minor version bump, and all other types will trigger a patch version bump.

Ensure your CI workflows are passing; seek approval from teammates and address any feedback; seek any explicit approvals required by the CODEOWNERS file. You may merge the PR as soon as all requirements are met, and a new release and tag will be automatically created for you.

### Automatic Updates

The shared configuration and workflow files in this repository are largely managed through the [launch-terraform-skeleton](https://github.com/launchbynttdata/launch-terraform-skeleton) repository. Outside of perhaps the `.gitignore` to account for specific files being generated by certain Terraform modules (e.g. Lambda functions), there should not be much cause to update these files on a per-repo basis, and making changes to them individually is discouraged.

If desired, you can check for and run these updates locally in a branch if you have the `copier` tool installed. Some example commands are included below:

```
# Check for updates, optionally checking prerelease versions
copier check-update [--prereleases]

# Run an update, using default answers if there are any. We use tasks, which requires --trust to be set.
copier update --defaults --trust [--prereleases]

# Recopy from the source, and --overwrite all templated files in the process
copier recopy --defaults --trust --overwrite [--prereleases]
```

Automatic updates will run through a scheduled workflow, and if the post-update tests are successful, the Pull Request created will automatically merge. Conflicts in the update or failures to test may leave a Pull Request outstanding, which needs to be addressed by a Launch Engineer.
