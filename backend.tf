terraform {
  backend "s3" {
    bucket   = "n8n-ecs-terraform-state"
    key      = "n8n-ecs/terraform.tfstate"
    region   = "ap-southeast-5"
    dynamodb_table = "n8n-ecs-terraform-locks"
    encrypt        = true
  }
}