aws_region = "us-west-2"

# Naming convention configuration
logical_product_family  = "launch"
logical_product_service = "efs"
region                  = "uswest2"
class_env               = "dev"
instance_env            = 1
instance_resource       = "001"

# Access Point naming (optional)
access_point_name = "complete-efs-access-point"

# EFS file system configuration
encrypted        = true
performance_mode = "generalPurpose"
throughput_mode  = "bursting"



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

tags = {
  Environment = "dev"
  Example     = "complete"
  Application = "efs-access-point"
}
