variable "cluster_name" {
  description = "Name of the ECS cluster"
  default     = "ecs-ecr-cluster"
}

variable "name_prefix" {
  description = "Prefix to use for resource names"
  default     = "ecs-ecr-demo"
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