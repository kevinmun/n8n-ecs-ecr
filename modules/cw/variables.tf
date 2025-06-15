variable "name_prefix" {
  description = "Prefix to use for resource names"
  type        = string
}

variable "distribution_id" {
  description = "CloudFront distribution ID"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain CloudFront logs"
  type        = number
  default     = 30
}

variable "error_threshold" {
  description = "Threshold for error rate alarms"
  type        = number
  default     = 5
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for alarm notifications"
  type        = string
}