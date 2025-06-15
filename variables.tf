variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "ecr_repository_name" {
  description = "Name of the existing ECR repository"
  type        = string
  default     = "ecs-ecr-demo"
}

variable "aws_account_id" {
  description = "AWS Account ID for ECR registry"
  type        = string
  default     = ""
}

variable "task_cpu" {
  description = "CPU units for the ECS task"
  type        = string
  default     = "256"
}

variable "task_memory" {
  description = "Memory for the ECS task in MB"
  type        = string
  default     = "512"
}

variable "service_desired_count" {
  description = "Desired count of tasks in the ECS service"
  type        = number
  default     = 1
}

variable "waf_rate_limit" {
  description = "Maximum number of requests allowed in a 5-minute period from a single IP address"
  type        = number
  default     = 1000
}

variable "waf_blocked_countries" {
  description = "List of country codes to block (ISO 3166-1 alpha-2 format)"
  type        = list(string)
  default     = []
}