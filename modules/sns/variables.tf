variable "name_prefix" {
  description = "Prefix to use for resource names"
  type        = string
}

variable "email_addresses" {
  description = "List of email addresses to notify"
  type        = list(string)
  default     = []
}