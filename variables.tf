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

variable "notification_emails" {
  description = "List of email addresses to notify for alarms"
  type        = list(string)
  default     = []
}