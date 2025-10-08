output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "load_balancer_dns" {
  description = "The DNS name of the load balancer"
  value       = module.alb.load_balancer_dns
}

output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = module.cloudfront.distribution_domain_name
}

output "cloudwatch_dashboard" {
  description = "CloudWatch dashboard name"
  value       = module.cloudwatch.dashboard_name
}

output "efs_file_system_id" {
  description = "EFS file system ID for n8n data"
  value       = module.efs.file_system_id
}

output "n8n_url" {
  description = "n8n application URL via CloudFront"
  value       = "https://${module.cloudfront.distribution_domain_name}"
}

output "logs_bucket" {
  description = "The name of the S3 bucket for logs"
  value       = module.s3.bucket_name
}

output "sns_topic_arn" {
  description = "The ARN of the SNS topic for notifications"
  value       = module.sns.topic_arn
}
