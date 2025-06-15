# ECS-ECR Demo Application

This project demonstrates how to deploy a containerized web application to AWS using Amazon ECS (Elastic Container Service) with Fargate, Amazon ECR (Elastic Container Registry), and Amazon CloudFront.

## Architecture

The application uses the following AWS services and components:

- **Amazon ECR**: Stores the Docker container image
- **Amazon ECS with Fargate**: Runs the containerized application without managing servers
- **Application Load Balancer**: Distributes traffic to the ECS tasks
- **Amazon CloudFront**: Provides global content delivery and HTTPS termination
- **Amazon S3**: Stores CloudFront access logs
- **Amazon CloudWatch**: Monitors and alerts on application metrics
- **Amazon SNS**: Sends notifications for alarms
- **VPC with public subnets**: Provides the networking infrastructure
- **IAM Roles**: Grants necessary permissions for ECS task execution

```
                                  +-------------+
                                  |             |
                                  |    Users    |
                                  |             |
                                  +------+------+
                                         |
                                         | HTTPS
                                         v
                                  +-------------+
                                  |             |
                                  | CloudFront  |
                                  |             |
                                  +------+------+
                                         |
                                         | HTTP
                                         v
                                  +-------------+
                                  |             |
                                  |     ALB     |
                                  |             |
                                  +------+------+
                                         |
                                         | Route Traffic
                                         v
+------------------+            +---------------+
|                  |            |               |
| ECR Repository   +----------->|  ECS Cluster  |
|                  |  Pull      |               |
+------------------+  Images    +-------+-------+
                                        |
                                        | Manage
                       +----------------+-----------------+
                       |                                  |
               +-------+-------+                  +-------+-------+
               |               |                  |               |
               |  ECS Task 1   |                  |  ECS Task 2   |
               | (Fargate)     |                  | (Fargate)     |
               |               |                  |               |
               +---------------+                  +---------------+

+------------------+            +------------------+            +------------------+
|                  |            |                  |            |                  |
|    CloudWatch    |<-----------+    CloudFront    +----------->|       S3         |
|    Monitoring    |   Metrics  |                  |    Logs    |     Logging      |
|                  |            |                  |            |                  |
+--------+---------+            +------------------+            +------------------+
         |
         | Alarms
         v
+------------------+
|                  |
|       SNS        |
|  Notifications   |
|                  |
+------------------+
```

## Project Structure

```
.
├── docker/
│   ├── Dockerfile        # NGINX container configuration
│   └── index.html        # Simple web page to serve
├── modules/
│   ├── vpc/              # VPC infrastructure module
│   ├── ecr/              # ECR repository module
│   ├── ecs/              # ECS cluster and service module
│   ├── alb/              # Application Load Balancer module
│   ├── cf/               # CloudFront distribution module
│   ├── s3/               # S3 bucket for logs module
│   ├── sns/              # SNS notifications module
│   └── cw/               # CloudWatch monitoring module
├── main.tf               # Main Terraform configuration
├── variables.tf          # Terraform variables
├── outputs.tf            # Terraform outputs
├── ecr_push.sh           # Script to build and push Docker image to ECR
└── README.md             # This file
```

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform installed
- Docker installed
- Existing ECR repository

## Deployment Steps

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Format Terraform Code

```bash
terraform fmt
```

### 3. Prepare Container Image

**If you don't have an image in ECR yet:**
```bash
chmod +x ecr_push.sh
./ecr_push.sh
```

This script will:
- Build the Docker image from the Dockerfile in the docker directory
- Tag the image with the ECR repository URL
- Push the image to the ECR repository

**If you already have an image in ECR:**
You can skip this step and proceed to the next one.

### 4. Plan Terraform Deployment

```bash
terraform plan -out=tfplan
```

### 5. Apply Terraform Configuration

```bash
terraform apply tfplan
```

Or simply:

```bash
terraform apply -var='notification_emails=["your.email@example.com"]'
```

### 6. Access the Application

After deployment is complete, you can access the application using the CloudFront domain name, which is available in the Terraform outputs:

```bash
terraform output cloudfront_domain_name
```

You can also access the application directly via the ALB:

```bash
terraform output load_balancer_dns
```

## Monitoring and Logging

The infrastructure includes CloudWatch monitoring and logging for the CloudFront distribution:

- **CloudWatch Log Group**: Captures CloudFront logs with a 30-day retention period
- **CloudWatch Alarms**: Monitors for 403 and 5xx error rates, triggering when they exceed thresholds
- **CloudWatch Dashboard**: Provides visualization of CloudFront metrics including requests and error rates
- **S3 Bucket**: Stores CloudFront access logs with lifecycle policies
- **SNS Topic**: Sends notifications when alarms are triggered

To access the CloudWatch Dashboard:
```bash
aws cloudwatch get-dashboard --dashboard-name $(terraform output -raw cloudwatch_dashboard)
```

## Cleaning Up

To avoid incurring charges, destroy the resources when you're done:

```bash
terraform destroy
```

**Note about ECR Repository:** The ECR repository is referenced as a data source and not managed by Terraform. If you need to delete the repository and all its images, you'll need to:

1. Uncomment and modify the `aws_ecr_repository` resource in the ECR module
2. Set `force_delete = true` in the resource configuration
3. Update the data source to reference this resource instead
4. Run `terraform apply` followed by `terraform destroy`

**WARNING:** Using `force_delete = true` will delete all images in the repository when destroyed.

## Security Considerations

- The application is deployed in public subnets with a public load balancer for demonstration purposes
- CloudFront provides HTTPS using its default certificate
- CloudWatch alarms monitor for suspicious error patterns
- In a production environment, consider using private subnets for the ECS tasks and implementing additional security measures
- The security group allows inbound traffic on ports 80 and 443

## Customization

- Modify the `docker/index.html` file to change the web content
- Update the module configurations in `main.tf` to adjust the infrastructure
- Edit the task definition in the ECS module to change container specifications
- Adjust CloudWatch alarm thresholds in the CW module
- Add additional email addresses to the SNS notifications

## Terraform Null Resources

This project uses Terraform null resources for several important tasks:

### Output Collection
A null resource in the main configuration collects all important infrastructure outputs into a single text file:
```terraform
resource "null_resource" "outputs" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "VPC ID: ${module.vpc.vpc_id}" > outputs.txt
      echo "ECR Repository URL: ${module.ecr.repository_url}" >> outputs.txt
      # Additional outputs...
    EOT
  }
}
```

### ECR Instructions
A null resource in the ECR module provides helpful instructions about the ECR repository:
```terraform
resource "null_resource" "ecr_instructions" {
  provisioner "local-exec" {
    command = <<-EOT
      echo "INFO: Using existing ECR repository: ${var.repository_name}"
      echo "IMPORTANT: If you haven't pushed an image yet, run: ./ecr_push.sh"
    EOT
  }
}
```

For more information about Terraform null resources and their uses in DevOps automation, refer to:
[Terraform null_resource: Your Secret Weapon for DevOps Automation](https://technodiaryvishnu.hashnode.dev/terraform-nullresource-your-secret-weapon-for-devops-automation)

## Module Structure

### VPC Module
Creates the networking infrastructure including VPC, subnets, route tables, and security groups.

### ECR Module
References an existing ECR repository.

### ALB Module
Creates the Application Load Balancer, target group, and HTTP listener.

### CloudFront Module
Creates a CloudFront distribution with the ALB as its origin, providing global content delivery and HTTPS.

### S3 Module
Creates an S3 bucket for storing CloudFront access logs with lifecycle policies.

### SNS Module
Creates an SNS topic for alarm notifications with email subscriptions.

### CloudWatch Module
Creates CloudWatch alarms, log groups, and dashboards for monitoring CloudFront metrics.

### ECS Module
Creates the ECS cluster, task definition, and service that runs the containerized application.