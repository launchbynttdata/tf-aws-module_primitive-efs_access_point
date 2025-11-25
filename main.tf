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

resource "aws_efs_access_point" "this" {

  file_system_id = var.efs_file_system_id

  dynamic "posix_user" {
    for_each = var.posix_user != null ? [var.posix_user] : []
    content {
      uid            = posix_user.value.uid
      gid            = posix_user.value.gid
      secondary_gids = posix_user.value.secondary_gids != null ? posix_user.value.secondary_gids : []
    }
  }

  dynamic "root_directory" {
    for_each = var.root_directory != null ? [var.root_directory] : []
    content {
      path = root_directory.value.path

      dynamic "creation_info" {
        for_each = root_directory.value.creation_info != null ? [root_directory.value.creation_info] : []
        content {
          owner_uid   = creation_info.value.owner_uid
          owner_gid   = creation_info.value.owner_gid
          permissions = creation_info.value.permissions
        }
      }
    }
  }

  tags = local.tags
}
