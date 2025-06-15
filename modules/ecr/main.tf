# Get existing ECR repository using data source
data "aws_ecr_repository" "repo" {
  name = var.repository_name
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