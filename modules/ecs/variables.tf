variable "cluster_name" {
  description = "Name of the ECS cluster"
  default     = "ecs-ecr-cluster"
}

variable "name_prefix" {
  description = "Prefix to use for resource names"
  default     = "n8n-ecs"
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "security_group_id" {
  description = "ID of the security group"
  type        = string
}

variable "ecr_repository_url" {
  description = "URL of the ECR repository"
  type        = string
}

variable "task_cpu" {
  description = "CPU units for the task"
  default     = "256"
}

variable "task_memory" {
  description = "Memory for the task in MB"
  default     = "512"
}

variable "service_desired_count" {
  description = "Desired count of tasks in the service"
  default     = 1
}

variable "target_group_arn" {
  description = "ARN of the target group for the load balancer"
  type        = string
}

# EFS Variables
variable "efs_file_system_id" {
  description = "EFS file system ID for n8n data storage"
  type        = string
}

variable "efs_access_point_id" {
  description = "EFS access point ID for n8n data"
  type        = string
}

# n8n Configuration Variables
variable "n8n_host" {
  description = "n8n host configuration"
  type        = string
  default     = "0.0.0.0"
}

variable "webhook_url" {
  description = "Webhook URL for n8n (typically CloudFront domain)"
  type        = string
}

variable "timezone" {
  description = "Timezone for n8n"
  type        = string
  default     = "UTC"
}

variable "aws_region" {
  description = "AWS region for CloudWatch logs"
  type        = string
}
