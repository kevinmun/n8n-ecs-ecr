# S3 bucket for CloudFront logs
resource "aws_s3_bucket" "logs" {
  bucket = "${var.name_prefix}-logs-${random_string.suffix.result}"
  
  tags = {
    Name = "${var.name_prefix}-logs"
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 bucket policy to allow CloudFront to write logs
resource "aws_s3_bucket_policy" "logs_policy" {
  bucket = aws_s3_bucket.logs.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action = "s3:PutObject"
        Resource = "${aws_s3_bucket.logs.arn}/${var.log_prefix}/*"
      }
    ]
  })
}

# S3 bucket lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "logs_lifecycle" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "log-expiration"
    status = "Enabled"

    expiration {
      days = var.log_retention_days
    }
  }
}