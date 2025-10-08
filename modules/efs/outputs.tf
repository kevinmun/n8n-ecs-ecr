output "file_system_id" {
  description = "EFS file system ID"
  value       = aws_efs_file_system.n8n_storage.id
}

output "file_system_arn" {
  description = "EFS file system ARN"
  value       = aws_efs_file_system.n8n_storage.arn
}

output "access_point_id" {
  description = "EFS access point ID for n8n data"
  value       = aws_efs_access_point.n8n_data.id
}

output "access_point_arn" {
  description = "EFS access point ARN for n8n data"
  value       = aws_efs_access_point.n8n_data.arn
}

output "security_group_id" {
  description = "Security group ID for EFS"
  value       = aws_security_group.efs.id
}
