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

variable "aws_region" {
  description = "AWS region where the example deploys resources."
  type        = string
}

# Naming convention variables
variable "logical_product_family" {
  description = "The logical product family name."
  type        = string
  default     = null
}

variable "logical_product_service" {
  description = "The logical product service name."
  type        = string
  default     = null
}

variable "region" {
  description = "AWS region abbreviation (e.g., use, mde, euw for us-east-1, etc.)"
  type        = string
  default     = null
}

variable "class_env" {
  description = "Environment class (e.g., dev, qa, prod)."
  type        = string
  default     = null
}

variable "instance_env" {
  description = "Instance environment number for uniqueness."
  type        = number
  default     = null
}

variable "instance_resource" {
  description = "Instance resource identifier."
  type        = string
  default     = null
}

variable "resource_names_map" {
  description = "A map to define resource naming conventions."
  type = map(object({
    name       = string
    max_length = number
  }))
  default = {
    efs = {
      name       = "efs"
      max_length = 255
    }
  }
}

# EFS file system configuration variables
# Note: creation_token and name are derived from the resource_names module
# No defaults are set to ensure explicit configuration via the naming module

variable "encrypted" {
  description = "Enable encryption at rest for the EFS file system."
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key to be used to encrypt the filesystem."
  type        = string
  default     = null
}

variable "performance_mode" {
  description = "The file system performance mode. Valid values: generalPurpose, maxIO."
  type        = string
  default     = "generalPurpose"

  validation {
    condition     = contains(["generalPurpose", "maxIO"], var.performance_mode)
    error_message = "Performance mode must be either 'generalPurpose' or 'maxIO'."
  }
}

variable "throughput_mode" {
  description = "Throughput mode for the file system. Valid values: bursting, provisioned."
  type        = string
  default     = "bursting"

  validation {
    condition     = contains(["bursting", "provisioned"], var.throughput_mode)
    error_message = "Throughput mode must be either 'bursting' or 'provisioned'."
  }
}

variable "creation_token" {
  description = "A unique name used as reference when creating the EFS. If null, will use generated name from resource_names module"
  type        = string
  default     = null
}

variable "name" {
  description = "Optional name for the EFS file system. If provided, will be added as a 'Name' tag. If null, will use generated name from resource_names module"
  type        = string
  default     = null
}

variable "access_point_name" {
  description = "Optional name for the EFS access point. If provided, will be added as a 'Name' tag."
  type        = string
  default     = null
}

variable "lifecycle_policy" {
  description = "A lifecycle_policy block as defined below."
  type = object({
    transition_to_ia                    = optional(string)
    transition_to_primary_storage_class = optional(string)
    transition_to_archive               = optional(string)
  })
  default = null
}

variable "protection" {
  description = "A protection block as defined below."
  type = object({
    replication_overwrite = optional(string)
  })
  default = null
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
