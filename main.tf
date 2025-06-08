provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
}

data "aws_availability_zones" "available" {}

resource "aws_security_group" "ecs_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecr_repository" "demo" {
  name = "ecs-ecr-demo"
}

resource "aws_ecs_cluster" "main" {
  name = "ecs-ecr-cluster"
}

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

resource "aws_ecs_task_definition" "app" {
  family                   = "demo-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_exec.arn

  container_definitions = jsonencode([{
    name      = "app"
    image     = "${aws_ecr_repository.demo.repository_url}:latest"
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
  }])
}

resource "aws_lb" "app_lb" {
  name               = "ecs-demo-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_sg.id]
  subnets            = aws_subnet.subnet[*].id
}

resource "aws_lb_target_group" "app_tg" {
  name     = "ecs-demo-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "ip"
  health_check {
    path = "/"
  }
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_ecs_service" "app" {
  name            = "ecs-demo-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets         = aws_subnet.subnet[*].id
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "app"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.app_listener]
}