# ECS-ECR Demo Application

This project demonstrates how to deploy a containerized web application to AWS using Amazon ECS (Elastic Container Service) with Fargate and Amazon ECR (Elastic Container Registry).

## Architecture

The application uses the following AWS services and components:

- **Amazon ECR**: Stores the Docker container image
- **Amazon ECS with Fargate**: Runs the containerized application without managing servers
- **Application Load Balancer**: Distributes traffic to the ECS tasks
- **VPC with public subnets**: Provides the networking infrastructure
- **IAM Roles**: Grants necessary permissions for ECS task execution

![](<arch.drawio (1).png>)

## Project Structure

```
.
├── docker/
│   ├── Dockerfile        # NGINX container configuration
│   └── index.html        # Simple web page to serve
├── .terraform/           # Terraform state directory
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

## Deployment Steps

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Apply Terraform Configuration

```bash
terraform apply
```

This will create all the necessary AWS resources including the VPC, subnets, security groups, ECR repository, ECS cluster, and load balancer.

### 3. Build and Push Docker Image

```bash
chmod +x ecr_push.sh
./ecr_push.sh
```

This script will:
- Build the Docker image from the Dockerfile in the docker directory
- Tag the image with the ECR repository URL
- Push the image to the ECR repository

### 4. Access the Application

After deployment is complete, you can access the application using the load balancer URL, which is available in the Terraform outputs:

```bash
terraform output alb_dns_name
```

## Cleaning Up

To avoid incurring charges, destroy the resources when you're done:

```bash
terraform destroy
```

## Security Considerations

- The application is deployed in public subnets with a public load balancer for demonstration purposes
- In a production environment, consider using private subnets for the ECS tasks and implementing additional security measures
- The security group allows inbound traffic on port 80 only

## Customization

- Modify the `docker/index.html` file to change the web content
- Update the `main.tf` file to adjust the infrastructure configuration
- Edit the task definition in `main.tf` to change container specifications
