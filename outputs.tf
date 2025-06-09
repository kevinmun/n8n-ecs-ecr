output "load_balancer_url" {
  value = aws_lb.app_lb.dns_name
}

output "ecs" {
  value = {
    cluster_name    = aws_ecs_cluster.main.name
    service_name    = aws_ecs_service.app.name
    task_definition = aws_ecs_task_definition.app.arn
  }
}