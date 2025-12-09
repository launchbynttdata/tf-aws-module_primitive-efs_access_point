# Complete example configuration for EFS Access Point
# This example demonstrates all available features and configurations
# Copy this file to test.tfvars and customize the values as needed

# general variables
aws_region = "us-east-2"

# Naming Module Configuration
naming_logical_product_family  = "launch"
naming_logical_product_service = "efs"
naming_class_env               = "sandbox"
naming_instance_env            = 0
naming_instance_resource       = 0
# naming_region is pulled from the aws_region variable

naming_resource_names_map = {
  efs_fs = {
    name       = "fs"
    max_length = 255
  }
  efs_ap = {
    name       = "ap"
    max_length = 60
  }
}

# EFS file system configuration
efs_fs_encrypted        = true
efs_fs_performance_mode = "generalPurpose"
efs_fs_throughput_mode  = "bursting"
efs_fs_name             = "complete-efs-file-system"

# EFS Access Point Configuration
# naming (optional) - If not given is derived from the Naming Module
name = "complete-efs-access-point"

posix_user = {
  uid            = 1000
  gid            = 1000
  secondary_gids = [1001, 1002]
}

root_directory = {
  path = "/data"
  creation_info = {
    owner_uid   = 1000
    owner_gid   = 1000
    permissions = "755"
  }
}


# Tags to apply to the EFS example and all resources
tags = {
  Environment = "dev"
  Module      = "efs_access_point"
  Example     = "complete-fixed-name"
  Application = "web-app"
  ManagedBy   = "Terraform"
  CostCenter  = "engineering"
}
