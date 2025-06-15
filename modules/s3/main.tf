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

# Enable server-side encryption for the S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "logs_encryption" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
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


# Enable ACLs for CloudFront logging
resource "aws_s3_bucket_ownership_controls" "logs_ownership" {
  bucket = aws_s3_bucket.logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "logs_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.logs_ownership]
  bucket     = aws_s3_bucket.logs.id
  acl        = "private"
}

# Grant CloudFront log delivery permissions
resource "aws_s3_bucket_acl" "logs_delivery_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.logs_ownership]
  bucket     = aws_s3_bucket.logs.id

  access_control_policy {
    owner {
      id = data.aws_canonical_user_id.current.id
    }

    grant {
      grantee {
        id   = data.aws_canonical_user_id.current.id
        type = "CanonicalUser"
      }
      permission = "FULL_CONTROL"
    }

    grant {
      grantee {
        type = "Group"
        uri  = "http://acs.amazonaws.com/groups/s3/LogDelivery"
      }
      permission = "WRITE"
    }

    grant {
      grantee {
        type = "Group"
        uri  = "http://acs.amazonaws.com/groups/s3/LogDelivery"
      }
      permission = "READ_ACP"
    }
  }
}

# Get current canonical user ID
data "aws_canonical_user_id" "current" {}


resource "aws_s3_bucket_lifecycle_configuration" "logs_lifecycle" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "log-expiration"
    status = "Enabled"

    filter {
      prefix = "${var.log_prefix}/"
    }

    expiration {
      days = var.log_retention_days
    }
  }
}
