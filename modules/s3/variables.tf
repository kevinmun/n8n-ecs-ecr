variable "name_prefix" {
  description = "Prefix to use for resource names"
  type        = string
}

variable "log_prefix" {
  description = "Prefix for log objects in the bucket"
  type        = string
  default     = "cloudfront-logs"
}

variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 30
}