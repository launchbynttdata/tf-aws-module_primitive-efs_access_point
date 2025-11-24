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

variable "efs_file_system_id" {
  description = "The ID of the EFS file system"
  type        = string
}

variable "posix_user" {
  description = "A POSIX user identity block. Enforces a user identity for all file system requests made through the access point."
  type = object({
    uid            = number
    gid            = number
    secondary_gids = optional(list(number))
  })
  default = null
}

variable "root_directory" {
  description = "A root directory block. Specifies the directory on the EFS file system that the access point provides access to."
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

variable "name" {
  description = "Name tag for the access point resource. If provided, will be added as a 'Name' tag."
  type        = string
  validation {
    condition     = var.name != null && var.name != ""
    error_message = "Name is required and cannot be empty."
  }
}

variable "tags" {
  description = "A map of tags to assign to the EFS file system"
  type        = map(string)
  default     = {}
}
