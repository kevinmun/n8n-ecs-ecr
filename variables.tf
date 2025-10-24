variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "ap-southeast-5"
}

variable "ecr_repository_name" {
  description = "Name of the existing ECR repository"
  type        = string
  default     = "n8n-ecs"
}

variable "task_cpu" {
  description = "CPU units for the ECS task"
  type        = number
  default     = 512
}

variable "task_memory" {
  description = "Memory for the ECS task in MiB"
  type        = number
  default     = 1024
}

variable "timezone" {
  description = "Timezone for n8n application"
  type        = string
  default     = "UTC"
}

variable "service_desired_count" {
  description = "Desired count of tasks in the ECS service"
  type        = number
  default     = 1
}

variable "email_addresses" {
  description = "List of email addresses to notify"
  type        = list(string)
  default     = []
}
