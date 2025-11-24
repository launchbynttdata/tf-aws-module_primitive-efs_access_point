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

# general Variables

variable "aws_region" {
  type        = string
  description = <<EOF
    (Required) The location where the resource will be created. Must not have spaces
    For example, us-east-1, us-west-2, eu-west-1, etc.
  EOF
  nullable    = false

  validation {
    condition     = length(regexall("\\b \\b", var.aws_region)) == 0
    error_message = "Spaces between the words are not allowed."
  }
}

# Naming Module Variables
variable "naming_logical_product_family" {
  type        = string
  description = <<EOF
    (Required) Name of the product family for which the resource is created.
    Example: org_name, department_name.
  EOF
  nullable    = false
  default     = "launch"

  validation {
    condition     = can(regex("^[_\\-A-Za-z0-9]+$", var.naming_logical_product_family))
    error_message = "The variable must contain letters, numbers, -, _, and .."
  }
}

variable "naming_logical_product_service" {
  type        = string
  description = <<EOF
    (Required) Name of the product service for which the resource is created.
    For example, backend, frontend, middleware etc.
  EOF
  nullable    = false
  default     = "backend"

  validation {
    condition     = can(regex("^[_\\-A-Za-z0-9]+$", var.naming_logical_product_service))
    error_message = "The variable must contain letters, numbers, -, _, and .."
  }
}

variable "naming_instance_resource" {
  type        = number
  description = "Number that represents the instance of the resource."
  default     = 0

  validation {
    condition     = var.naming_instance_resource >= 0 && var.naming_instance_resource <= 100
    error_message = "Instance number should be between 0 to 100."
  }
}

variable "naming_instance_env" {
  type        = number
  description = "Number that represents the instance of the environment."
  default     = 0

  validation {
    condition     = var.naming_instance_env >= 0 && var.naming_instance_env <= 999
    error_message = "Instance number should be between 0 to 999."
  }
}

variable "naming_class_env" {
  type        = string
  default     = "dev"
  description = "(Required) Environment where resource is going to be deployed. For example. dev, qa, uat"
  nullable    = false

  validation {
    condition     = length(regexall("\\b \\b", var.naming_class_env)) == 0
    error_message = "Spaces between the words are not allowed."
  }
}

variable "naming_resource_names_map" {
  description = "A map of key to resource_name that will be used by tf-launch-module_library-resource_name to generate resource names"
  type = map(object(
    {
      name       = string
      max_length = optional(number, 60)
    }
  ))
  default = {}
}

# variable "naming_region" {
#   type        = string
#   description = <<EOF
#     (Required) The location where the resource will be created. Must not have spaces
#     For example, us-east-1, us-west-2, eu-west-1, etc.
#   EOF
#   nullable    = false

#   validation {
#     condition     = length(regexall("\\b \\b", var.naming_region)) == 0
#     error_message = "Spaces between the words are not allowed."
#   }
# }


# EFS file system configuration variables
# Note: creation_token and name are derived from the resource_names module
# No defaults are set to ensure explicit configuration via the naming module


variable "efs_fs_creation_token" {
  description = "A unique name used as reference when creating the EFS. If null, will use generated name from resource_names module"
  type        = string
  default     = null
}


variable "efs_fs_encrypted" {
  description = "Enable encryption at rest for the EFS file system."
  type        = bool
  default     = true
}

variable "efs_fs_kms_key_id" {
  description = "The ARN for the KMS encryption key to be used to encrypt the filesystem."
  type        = string
  default     = null
}

variable "efs_fs_performance_mode" {
  description = "The file system performance mode. Valid values: generalPurpose, maxIO."
  type        = string
  default     = "generalPurpose"

  validation {
    condition     = contains(["generalPurpose", "maxIO"], var.efs_fs_performance_mode)
    error_message = "Performance mode must be either 'generalPurpose' or 'maxIO'."
  }
}

variable "efs_fs_throughput_mode" {
  description = "Throughput mode for the file system. Valid values: bursting, provisioned."
  type        = string
  default     = "bursting"

  validation {
    condition     = contains(["bursting", "provisioned"], var.efs_fs_throughput_mode)
    error_message = "Throughput mode must be either 'bursting' or 'provisioned'."
  }
}


variable "efs_fs_lifecycle_policy" {
  description = "A lifecycle_policy block as defined below."
  type = object({
    transition_to_ia                    = optional(string)
    transition_to_primary_storage_class = optional(string)
    transition_to_archive               = optional(string)
  })
  default = null
}

variable "efs_fs_protection" {
  description = "A protection block as defined below."
  type = object({
    replication_overwrite = optional(string)
  })
  default = null
}

variable "efs_fs_name" {
  description = "Optional name for the EFS file system. If provided, will be added as a 'Name' tag. If null, will use generated name from resource_names module"
  type        = string
  default     = null
}

# EFS Access Point configuration variables
variable "name" {
  description = "Optional name for the EFS access point. If provided, will be added as a 'Name' tag."
  type        = string
  default     = null
}

variable "posix_user" {
  description = "POSIX user configuration for the access point"
  type = object({
    uid            = number
    gid            = number
    secondary_gids = optional(list(number))
  })
  default = null
}

variable "root_directory" {
  description = "Root directory configuration for the access point"
  type = object({
    path = string
    creation_info = optional(object({
      owner_uid   = number
      owner_gid   = number
      permissions = string
    }))
  })
  default = null
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Example     = "complete"
  }
}
