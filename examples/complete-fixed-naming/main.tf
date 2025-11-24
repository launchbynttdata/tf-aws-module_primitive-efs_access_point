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

module "resource_names" {
  # checkov:skip=CKV_TF_1: trusted module source
  source  = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version = "~> 2.0"

  for_each = var.naming_resource_names_map


  logical_product_family  = var.naming_logical_product_family
  logical_product_service = var.naming_logical_product_service
  region                  = join("", split("-", var.aws_region))
  class_env               = var.naming_class_env
  cloud_resource_type     = each.value.name
  instance_env            = var.naming_instance_env
  maximum_length          = each.value.max_length
  instance_resource       = var.naming_instance_resource
}

resource "aws_efs_file_system" "this" {
  creation_token = var.efs_fs_creation_token != null ? var.efs_fs_creation_token : module.resource_names["efs_fs"].standard
  encrypted      = var.efs_fs_encrypted
  kms_key_id     = var.efs_fs_kms_key_id

  performance_mode = var.efs_fs_performance_mode
  throughput_mode  = var.efs_fs_throughput_mode

  dynamic "lifecycle_policy" {
    for_each = var.efs_fs_lifecycle_policy != null ? [var.efs_fs_lifecycle_policy] : []
    content {
      transition_to_ia                    = lifecycle_policy.value.transition_to_ia
      transition_to_primary_storage_class = lifecycle_policy.value.transition_to_primary_storage_class
      transition_to_archive               = lifecycle_policy.value.transition_to_archive
    }
  }

  dynamic "protection" {
    for_each = var.efs_fs_protection != null ? [var.efs_fs_protection] : []
    content {
      replication_overwrite = protection.value.replication_overwrite
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.efs_fs_name != null ? var.efs_fs_name : module.resource_names["efs_fs"].standard
    }
  )
}

module "efs_access_point" {
  source = "../../"

  efs_file_system_id = aws_efs_file_system.this.id

  posix_user = var.posix_user

  root_directory = var.root_directory

  name = var.name != null ? var.name : module.resource_names["efs_ap"].standard

  tags = merge(
    {
      "ManagedBy" = "Terraform"
      "Name"      = var.name != null ? var.name : module.resource_names["efs_ap"].standard
    },
    var.tags,
  )
}
