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

output "access_point_id" {
  description = "The ID of the EFS access point"
  value       = aws_efs_access_point.this.id
}

output "access_point_arn" {
  description = "Amazon Resource Name of the access point"
  value       = aws_efs_access_point.this.arn
}

output "file_system_id" {
  description = "The ID of the EFS file system that the access point applies to"
  value       = aws_efs_access_point.this.file_system_id
}


output "owner_id" {
  description = "The AWS account ID that owns the access point resource"
  value       = aws_efs_access_point.this.owner_id
}

output "posix_user" {
  description = "The full POSIX identity, including the user ID, group ID, and secondary group IDs on the access point"
  value = var.posix_user != null ? {
    uid            = var.posix_user.uid
    gid            = var.posix_user.gid
    secondary_gids = try(var.posix_user.secondary_gids, null) != null && length(try(var.posix_user.secondary_gids, [])) > 0 ? var.posix_user.secondary_gids : null
  } : null
}

output "root_directory" {
  description = "The directory on the EFS file system that the access point exposes as the root directory to NFS clients"
  value       = try(aws_efs_access_point.this.root_directory[0], null)
}

output "tags" {
  description = "A map of tags assigned to the access point"
  value       = aws_efs_access_point.this.tags
}
