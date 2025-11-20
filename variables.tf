
variable "posix_user" {
  description = "POSIX user configuration for the access point"
  type = object({
    uid = number
    gid = number
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

variable "efs_file_system_id" {
  description = "The ID of the EFS file system"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}