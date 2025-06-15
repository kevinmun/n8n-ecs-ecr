# CloudWatch module for CloudFront monitoring

# CloudWatch Log Group for CloudFront logs
resource "aws_cloudwatch_log_group" "cloudfront_logs" {
  name              = "/aws/cloudfront/${var.distribution_id}"
  retention_in_days = var.log_retention_days
  
  tags = {
    Name = "${var.name_prefix}-cloudfront-logs"
  }
}

# CloudWatch Alarm for 403 errors
resource "aws_cloudwatch_metric_alarm" "cloudfront_403_errors" {
  alarm_name          = "${var.name_prefix}-cloudfront-403-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "403ErrorRate"
  namespace           = "AWS/CloudFront"
  period              = "300"
  statistic           = "Average"
  threshold           = var.error_threshold
  alarm_description   = "This alarm monitors CloudFront 403 error rate"
  
  dimensions = {
    DistributionId = var.distribution_id
    Region         = "Global"
  }
  
  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]
}

# CloudWatch Alarm for 5xx errors
resource "aws_cloudwatch_metric_alarm" "cloudfront_5xx_errors" {
  alarm_name          = "${var.name_prefix}-cloudfront-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "5xxErrorRate"
  namespace           = "AWS/CloudFront"
  period              = "300"
  statistic           = "Average"
  threshold           = var.error_threshold
  alarm_description   = "This alarm monitors CloudFront 5xx error rate"
  
  dimensions = {
    DistributionId = var.distribution_id
    Region         = "Global"
  }
  
  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]
}

# CloudWatch Dashboard for CloudFront metrics
resource "aws_cloudwatch_dashboard" "cloudfront_dashboard" {
  dashboard_name = "${var.name_prefix}-cloudfront-dashboard"
  
  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [ "AWS/CloudFront", "Requests", "DistributionId", "${var.distribution_id}", "Region", "Global" ],
          [ ".", "BytesDownloaded", ".", ".", ".", "." ],
          [ ".", "BytesUploaded", ".", ".", ".", "." ]
        ],
        "period": 300,
        "stat": "Sum",
        "region": "us-east-1",
        "title": "CloudFront Traffic"
      }
    },
    {
      "type": "metric",
      "x": 12,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [ "AWS/CloudFront", "4xxErrorRate", "DistributionId", "${var.distribution_id}", "Region", "Global" ],
          [ ".", "5xxErrorRate", ".", ".", ".", "." ],
          [ ".", "403ErrorRate", ".", ".", ".", "." ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "us-east-1",
        "title": "CloudFront Error Rates"
      }
    }
  ]
}
EOF
}