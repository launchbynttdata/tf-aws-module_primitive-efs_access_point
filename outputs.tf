
output "access_point_id" {
  description = "The ID of the EFS access point"
  value       = aws_efs_access_point.this.id
}

output "access_point_arn" {
  description = "Amazon Resource Name of the access point"
  value       = aws_efs_access_point.this.arn 
}