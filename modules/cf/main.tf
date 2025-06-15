# CloudFront distribution for ALB
resource "aws_cloudfront_distribution" "alb_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.name_prefix} CloudFront Distribution"
  default_root_object = "index.html"
  price_class         = var.price_class
  web_acl_id          = var.web_acl_id
  
  # ALB origin
  origin {
    domain_name = var.alb_dns_name
    origin_id   = "ALB-${var.name_prefix}"
    
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  
  # Default cache behavior
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "ALB-${var.name_prefix}"
    
    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
      headers = ["Host", "Origin"]
    }
    
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
  
  # Geo restrictions
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  
  # SSL certificate
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  
  tags = {
    Name = "${var.name_prefix}-cf-distribution"
  }
}