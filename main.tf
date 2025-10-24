provider "aws" {
  region = var.aws_region
}

# VPC Module
module "vpc" {
  source       = "./modules/vpc"
  vpc_cidr     = "10.0.0.0/16"
  subnet_count = 2
  name_prefix  = "n8n-ecs"
}

# ECR Module - Using existing repository
module "ecr" {
  source          = "./modules/ecr"
  repository_name = var.ecr_repository_name
}

# EFS Module for n8n persistent storage
module "efs" {
  source                = "./modules/efs"
  name_prefix           = "n8n-ecs"
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.subnet_ids
  ecs_security_group_id = module.vpc.security_group_id
}

# ALB Module
module "alb" {
  source            = "./modules/alb"
  name_prefix       = "n8n-ecs"
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.subnet_ids
  security_group_id = module.vpc.security_group_id
}

# ECS Module
module "ecs" {
  source                = "./modules/ecs"
  cluster_name          = "ecs-ecr-cluster"
  name_prefix           = "n8n-ecs"
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.subnet_ids
  security_group_id     = module.vpc.security_group_id
  ecr_repository_url    = module.ecr.repository_url
  target_group_arn      = module.alb.target_group_arn
  task_cpu              = var.task_cpu
  task_memory           = var.task_memory
  service_desired_count = var.service_desired_count
  
  # EFS Configuration
  efs_file_system_id    = module.efs.file_system_id
  efs_access_point_id   = module.efs.access_point_id
  
  # n8n Configuration
  n8n_host              = "0.0.0.0"
  webhook_url           = "https://${module.cloudfront.distribution_domain_name}"
  timezone              = var.timezone
  aws_region            = var.aws_region
}

# S3 Module for logs
module "s3" {
  source            = "./modules/s3"
  name_prefix       = "n8n-ecs"
  log_retention_days = 30
}

# SNS Module for notifications
module "sns" {
  source          = "./modules/sns"
  name_prefix     = "n8n-ecs"
  email_addresses = ["kevin_mkt@hotmail.com"]
}

# CloudFront Module
module "cloudfront" {
  source       = "./modules/cf"
  name_prefix  = "n8n-ecs"
  alb_dns_name = module.alb.load_balancer_dns
}

# CloudWatch Module for monitoring
module "cloudwatch" {
  source            = "./modules/cw"
  name_prefix       = "n8n-ecs"
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
      echo "=== n8n ECS Infrastructure Outputs ===" > outputs.txt
      echo "" >> outputs.txt
      echo "n8n Application URL: https://${module.cloudfront.distribution_domain_name}" >> outputs.txt
      echo "Load Balancer DNS: ${module.alb.load_balancer_dns}" >> outputs.txt
      echo "" >> outputs.txt
      echo "=== Infrastructure Details ===" >> outputs.txt
      echo "VPC ID: ${module.vpc.vpc_id}" >> outputs.txt
      echo "ECS Cluster Name: ${module.ecs.cluster_name}" >> outputs.txt
      echo "EFS File System ID: ${module.efs.file_system_id}" >> outputs.txt
      echo "ECR Repository URL: ${module.ecr.repository_url}" >> outputs.txt
      echo "" >> outputs.txt
      echo "=== Monitoring & Logging ===" >> outputs.txt
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
