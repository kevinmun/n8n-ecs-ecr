# SNS topic for CloudFront alarms
resource "aws_sns_topic" "alarms" {
  name = "${var.name_prefix}-alarms"
  
  tags = {
    Name = "${var.name_prefix}-alarms"
  }
}

# SNS topic subscription for email notifications
resource "aws_sns_topic_subscription" "email_subscription" {
  count     = length(var.email_addresses)
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.email_addresses[count.index]
}