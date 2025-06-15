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

# COMMENTED OUT: Use this if you want to create and manage the ECR repository with Terraform
# WARNING: Using force_delete=true will delete all images in the repository when destroyed
/*
resource "aws_ecr_repository" "repo" {
  name        = var.repository_name
  force_delete = true  # WARNING: This will delete all images when destroyed
  
  image_scanning_configuration {
    scan_on_push = true
  }
  
  encryption_configuration {
    encryption_type = "AES256"
  }
}
*/