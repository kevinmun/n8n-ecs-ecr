output "log_group_name" {
  description = "Name of the CloudWatch Log Group for CloudFront logs"
  value       = aws_cloudwatch_log_group.cloudfront_logs.name
}

output "dashboard_name" {
  description = "Name of the CloudWatch Dashboard for CloudFront metrics"
  value       = aws_cloudwatch_dashboard.cloudfront_dashboard.dashboard_name
}