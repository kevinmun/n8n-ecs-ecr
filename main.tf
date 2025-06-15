provider "aws" {
  region = var.aws_region
}

# Provider for global resources (WAF for CloudFront must be in us-east-1)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
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

# WAF Module - Must use us-east-1 for CloudFront WAF
module "waf" {
  source            = "./modules/waf"
  name_prefix       = "ecs-ecr-demo"
  rate_limit        = var.waf_rate_limit
  blocked_countries = var.waf_blocked_countries

  providers = {
    aws = aws.us_east_1
  }
}

# CloudFront Module
module "cloudfront" {
  source       = "./modules/cf"
  name_prefix  = "ecs-ecr-demo"
  alb_dns_name = module.alb.load_balancer_dns
  web_acl_id   = module.waf.web_acl_id
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
      echo "WAF Web ACL ID: ${module.waf.web_acl_id}" >> outputs.txt
    EOT
  }

  depends_on = [
    module.vpc,
    module.ecr,
    module.alb,
    module.ecs,
    module.waf,
    module.cloudfront
  ]
}