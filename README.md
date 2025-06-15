# ECS-ECR Demo Application

This project demonstrates how to deploy a containerized web application to AWS using Amazon ECS (Elastic Container Service) with Fargate, Amazon ECR (Elastic Container Registry), and Amazon CloudFront.

## Architecture

The application uses the following AWS services and components:

- **Amazon ECR**: Stores the Docker container image
- **Amazon ECS with Fargate**: Runs the containerized application without managing servers
- **Application Load Balancer**: Distributes traffic to the ECS tasks
- **Amazon CloudFront**: Provides global content delivery and HTTPS termination
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
│   └── cf/               # CloudFront distribution module
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
terraform apply
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

## Cleaning Up

To avoid incurring charges, destroy the resources when you're done:

```bash
terraform destroy
```

## Security Considerations

- The application is deployed in public subnets with a public load balancer for demonstration purposes
- CloudFront provides HTTPS using its default certificate
- In a production environment, consider using private subnets for the ECS tasks and implementing additional security measures
- The security group allows inbound traffic on ports 80 and 443

## Customization

- Modify the `docker/index.html` file to change the web content
- Update the module configurations in `main.tf` to adjust the infrastructure
- Edit the task definition in the ECS module to change container specifications

## Module Structure

### VPC Module
Creates the networking infrastructure including VPC, subnets, route tables, and security groups.

### ECR Module
References an existing ECR repository.

### ALB Module
Creates the Application Load Balancer, target group, and HTTP listener.

### ECS Module
Creates the ECS cluster, task definition, and service that runs the containerized application.

### CloudFront Module
Creates a CloudFront distribution with the ALB as its origin, providing global content delivery and HTTPS.