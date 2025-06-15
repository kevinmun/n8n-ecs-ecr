variable "repository_name" {
  description = "Name of the existing ECR repository"
  type        = string
}

variable "enable_replication" {
  description = "Whether to enable cross-region replication"
  type        = bool
  default     = false
}

variable "replication_region" {
  description = "Region to replicate the repository to"
  type        = string
  default     = ""
}

variable "registry_id" {
  description = "AWS account ID for the registry"
  type        = string
  default     = ""
}