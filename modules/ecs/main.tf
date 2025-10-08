# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = var.cluster_name
  
  tags = {
    Name = var.cluster_name
  }
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_exec" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = data.aws_iam_policy_document.ecs_task_exec_assume.json
}

data "aws_iam_policy_document" "ecs_task_exec_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_attach" {
  role       = aws_iam_role.ecs_task_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.name_prefix}-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_task_exec.arn

  volume {
    name = "n8n-data"
    efs_volume_configuration {
      file_system_id     = var.efs_file_system_id
      access_point_id    = var.efs_access_point_id
      transit_encryption = "ENABLED"
    }
  }

  container_definitions = jsonencode([{
    name  = "n8n"
    image = "docker.n8n.io/n8nio/n8n:latest"
    
    portMappings = [{
      containerPort = 5678
      hostPort      = 5678
      protocol      = "tcp"
    }]

    environment = [
      {
        name  = "N8N_HOST"
        value = var.n8n_host
      },
      {
        name  = "N8N_PORT"
        value = "5678"
      },
      {
        name  = "N8N_PROTOCOL"
        value = "http"
      },
      {
        name  = "WEBHOOK_URL"
        value = var.webhook_url
      },
      {
        name  = "GENERIC_TIMEZONE"
        value = var.timezone
      }
    ]

    mountPoints = [{
      sourceVolume  = "n8n-data"
      containerPath = "/home/node/.n8n"
      readOnly      = false
    }]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/${var.name_prefix}-n8n"
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }

    healthCheck = {
      command = [
        "CMD-SHELL",
        "wget --no-verbose --tries=1 --spider http://localhost:5678/healthz || exit 1"
      ]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 60
    }

    essential = true
  }])
}

# CloudWatch Log Group for n8n
resource "aws_cloudwatch_log_group" "n8n" {
  name              = "/ecs/${var.name_prefix}-n8n"
  retention_in_days = 30

  tags = {
    Name = "${var.name_prefix}-n8n-logs"
  }
}

# ECS Service
resource "aws_ecs_service" "app" {
  name            = "${var.name_prefix}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  launch_type     = "FARGATE"
  desired_count   = var.service_desired_count

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "n8n"
    container_port   = 5678
  }
}
