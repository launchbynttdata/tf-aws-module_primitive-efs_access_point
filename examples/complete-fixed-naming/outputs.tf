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

output "file_system_id" {
  description = "The ID of the EFS file system"
  value       = aws_efs_file_system.this.id
}

output "file_system_arn" {
  description = "The ARN of the EFS file system"
  value       = aws_efs_file_system.this.arn
}

output "access_point_id" {
  description = "The ID of the EFS access point"
  value       = module.efs_access_point.access_point_id
}

output "access_point_arn" {
  description = "The ARN of the EFS access point"
  value       = module.efs_access_point.access_point_arn
}

output "file_system_name" {
  description = "The Name tag of the EFS file system (if set)"
  value       = var.efs_fs_name
}

output "access_point_name" {
  description = "The Name tag of the EFS access point (if set)"
  value       = var.name
}

output "access_point_owner_id" {
  description = "The AWS account ID that owns the access point resource"
  value       = module.efs_access_point.owner_id
}

output "access_point_posix_user" {
  description = "The POSIX user identity configuration including secondary GIDs"
  value       = module.efs_access_point.posix_user
}

output "access_point_root_directory" {
  description = "The root directory configuration including creation info"
  value       = module.efs_access_point.root_directory
}

output "access_point_tags" {
  description = "Tags assigned to the access point"
  value       = module.efs_access_point.tags
}
