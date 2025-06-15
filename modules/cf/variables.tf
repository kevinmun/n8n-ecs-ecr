variable "name_prefix" {
  description = "Prefix to use for resource names"
  type        = string
}

variable "alb_dns_name" {
  description = "DNS name of the ALB"
  type        = string
}

variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_200" # Options: PriceClass_100, PriceClass_200, PriceClass_All
}

variable "logs_bucket" {
  description = "S3 bucket domain name for CloudFront logs"
  type        = string
  default     = ""
}