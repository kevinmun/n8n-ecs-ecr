provider "aws" {
  region = var.aws_region
}

# VPC Module
module "vpc" {
  source       = "./modules/vpc"
  vpc_cidr     = "10.0.0.0/16"
  subnet_count = 2
  name_prefix  = "ecs-ecr-demo"
}

# ECR Module - Using existing repository
module "ecr" {
  source          = "./modules/ecr"
  repository_name = var.ecr_repository_name
}

# ALB Module
module "alb" {
  source            = "./modules/alb"
  name_prefix       = "ecs-ecr-demo"
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.subnet_ids
  security_group_id = module.vpc.security_group_id
}

# ECS Module
module "ecs" {
  source                = "./modules/ecs"
  cluster_name          = "ecs-ecr-cluster"
  name_prefix           = "ecs-ecr-demo"
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.subnet_ids
  security_group_id     = module.vpc.security_group_id
  ecr_repository_url    = module.ecr.repository_url
  target_group_arn      = module.alb.target_group_arn
  task_cpu              = var.task_cpu
  task_memory           = var.task_memory
  service_desired_count = var.service_desired_count
}

# S3 Module for logs
module "s3" {
  source            = "./modules/s3"
  name_prefix       = "ecs-ecr-demo"
  log_retention_days = 30
}

# SNS Module for notifications
module "sns" {
  source          = "./modules/sns"
  name_prefix     = "ecs-ecr-demo"
  email_addresses = var.notification_emails
}

# CloudFront Module
module "cloudfront" {
  source       = "./modules/cf"
  name_prefix  = "ecs-ecr-demo"
  alb_dns_name = module.alb.load_balancer_dns
  logs_bucket  = module.s3.bucket_domain_name
}

# CloudWatch Module for monitoring
module "cloudwatch" {
  source            = "./modules/cw"
  name_prefix       = "ecs-ecr-demo"
  distribution_id   = module.cloudfront.distribution_id
  log_retention_days = 30
  error_threshold   = 5
  sns_topic_arn     = module.sns.topic_arn
}

# Null resource to output all values to a text file
resource "null_resource" "outputs" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "VPC ID: ${module.vpc.vpc_id}" > outputs.txt
      echo "ECR Repository URL: ${module.ecr.repository_url}" >> outputs.txt
      echo "ECS Cluster Name: ${module.ecs.cluster_name}" >> outputs.txt
      echo "Load Balancer DNS: ${module.alb.load_balancer_dns}" >> outputs.txt
      echo "CloudFront Domain Name: ${module.cloudfront.distribution_domain_name}" >> outputs.txt
      echo "CloudWatch Dashboard: ${module.cloudwatch.dashboard_name}" >> outputs.txt
      echo "S3 Logs Bucket: ${module.s3.bucket_name}" >> outputs.txt
      echo "SNS Topic ARN: ${module.sns.topic_arn}" >> outputs.txt
    EOT
  }

  depends_on = [
    module.vpc,
    module.ecr,
    module.alb,
    module.ecs,
    module.cloudfront,
    module.s3,
    module.sns,
    module.cloudwatch
  ]
}