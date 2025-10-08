# EFS File System
resource "aws_efs_file_system" "n8n_storage" {
  creation_token = "${var.name_prefix}-n8n-efs"
  
  performance_mode = "generalPurpose"
  throughput_mode  = "provisioned"
  provisioned_throughput_in_mibps = 10

  encrypted = true

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name = "${var.name_prefix}-n8n-efs"
  }
}

# EFS Mount Targets
resource "aws_efs_mount_target" "n8n_storage" {
  count           = length(var.subnet_ids)
  file_system_id  = aws_efs_file_system.n8n_storage.id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = [aws_security_group.efs.id]
}

# Security Group for EFS
resource "aws_security_group" "efs" {
  name_prefix = "${var.name_prefix}-efs-"
  vpc_id      = var.vpc_id

  ingress {
    description     = "NFS from ECS"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [var.ecs_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-efs-sg"
  }
}

# EFS Access Point for n8n
resource "aws_efs_access_point" "n8n_data" {
  file_system_id = aws_efs_file_system.n8n_storage.id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = "/n8n-data"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "755"
    }
  }

  tags = {
    Name = "${var.name_prefix}-n8n-access-point"
  }
}
