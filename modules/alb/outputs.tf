output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = aws_lb.app_lb.dns_name
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.app_tg.arn
}