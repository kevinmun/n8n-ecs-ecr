variable "name_prefix" {
  description = "Prefix to use for resource names"
  type        = string
}

variable "rate_limit" {
  description = "Maximum number of requests allowed in a 5-minute period from a single IP address"
  type        = number
  default     = 1000
}

variable "blocked_countries" {
  description = "List of country codes to block (ISO 3166-1 alpha-2 format)"
  type        = list(string)
  default     = []
}