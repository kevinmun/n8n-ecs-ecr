# Check if ECR repository exists
data "aws_ecr_repository" "repo" {
  name = var.repository_name
}

# Output message for users about ECR repository
resource "null_resource" "ecr_instructions" {
  provisioner "local-exec" {
    command = <<-EOT
      echo "INFO: Using existing ECR repository: ${var.repository_name}"
      echo "IMPORTANT: If you haven't pushed an image yet, run: ./ecr_push.sh"
    EOT
  }
}

# Enable cross-region replication if specified
resource "aws_ecr_replication_configuration" "replication" {
  count = var.enable_replication ? 1 : 0
  
  replication_configuration {
    rule {
      destination {
        region      = var.replication_region
        registry_id = var.registry_id
      }
    }
  }
}