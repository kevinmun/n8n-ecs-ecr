# AWS ECS-ECR Infrastructure Architecture Diagram

## Comprehensive Architecture Overview

```
                                    ┌─────────────────┐
                                    │                 │
                                    │     Internet    │
                                    │     Users       │
                                    │                 │
                                    └─────────┬───────┘
                                              │ HTTPS/HTTP
                                              │
                                    ┌─────────▼───────┐
                                    │                 │
                                    │   CloudFront    │
                                    │   Distribution  │
                                    │   (Global CDN)  │
                                    │                 │
                                    └─────────┬───────┘
                                              │ HTTP
                                              │
┌─────────────────────────────────────────────▼─────────────────────────────────────────────┐
│                                    AWS Region                                              │
│                                                                                            │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐ │
│  │                              VPC (10.0.0.0/16)                                     │ │
│  │                                                                                     │ │
│  │  ┌─────────────────────┐                    ┌─────────────────────┐                │ │
│  │  │   Public Subnet     │                    │   Public Subnet     │                │ │
│  │  │  (10.0.0.0/24)      │                    │  (10.0.1.0/24)      │                │ │
│  │  │   AZ-1              │                    │   AZ-2              │                │ │
│  │  │                     │                    │                     │                │ │
│  │  │  ┌───────────────┐  │                    │  ┌───────────────┐  │                │ │
│  │  │  │  ECS Task 1   │  │                    │  │  ECS Task 2   │  │                │ │
│  │  │  │  (Fargate)    │  │                    │  │  (Fargate)    │  │                │ │
│  │  │  │               │  │                    │  │               │  │                │ │
│  │  │  │ ┌───────────┐ │  │                    │  │ ┌───────────┐ │  │                │ │
│  │  │  │ │   NGINX   │ │  │                    │  │ │   NGINX   │ │  │                │ │
│  │  │  │ │Container  │ │  │                    │  │ │Container  │ │  │                │ │
│  │  │  │ │Port: 80   │ │  │                    │  │ │Port: 80   │ │  │                │ │
│  │  │  │ └───────────┘ │  │                    │  │ └───────────┘ │  │                │ │
│  │  │  └───────────────┘  │                    │  └───────────────┘  │                │ │
│  │  └─────────────────────┘                    └─────────────────────┘                │ │
│  │                                                                                     │ │
│  │  ┌─────────────────────────────────────────────────────────────────────────────┐   │ │
│  │  │                    Application Load Balancer                                │   │ │
│  │  │                         (Internet-facing)                                  │   │ │
│  │  │                                                                             │   │ │
│  │  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────────────────────────┐ │   │ │
│  │  │  │  Listener   │    │   Target    │    │        Health Checks           │ │   │ │
│  │  │  │  Port: 80   │───▶│   Group     │───▶│     /health (Port 80)          │ │   │ │
│  │  │  │             │    │             │    │                                 │ │   │ │
│  │  │  └─────────────┘    └─────────────┘    └─────────────────────────────────┘ │   │ │
│  │  └─────────────────────────────────────────────────────────────────────────────┘   │ │
│  │                                                                                     │ │
│  │  ┌─────────────────────────────────────────────────────────────────────────────┐   │ │
│  │  │                         Security Group                                     │   │ │
│  │  │                                                                             │   │ │
│  │  │  Inbound Rules:                    Outbound Rules:                         │   │ │
│  │  │  • HTTP (80) from 0.0.0.0/0       • All traffic to 0.0.0.0/0             │   │ │
│  │  │  • HTTPS (443) from 0.0.0.0/0                                              │   │ │
│  │  └─────────────────────────────────────────────────────────────────────────────┘   │ │
│  │                                                                                     │ │
│  │  ┌─────────────────────────────────────────────────────────────────────────────┐   │ │
│  │  │                        Internet Gateway                                    │   │ │
│  │  │                      (0.0.0.0/0 → IGW)                                     │   │ │
│  │  └─────────────────────────────────────────────────────────────────────────────┘   │ │
│  └─────────────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                            │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐ │
│  │                                ECS Cluster                                         │ │
│  │                                                                                     │ │
│  │  ┌─────────────────────────────────────────────────────────────────────────────┐   │ │
│  │  │                         ECS Service                                        │   │ │
│  │  │                                                                             │   │ │
│  │  │  • Launch Type: FARGATE                                                     │   │ │
│  │  │  • Desired Count: Configurable                                             │   │ │
│  │  │  • Task Definition: n8n-ecs-app                                       │   │ │
│  │  │  • Network Mode: awsvpc                                                    │   │ │
│  │  │  • CPU: Configurable (default: 256)                                       │   │ │
│  │  │  • Memory: Configurable (default: 512)                                    │   │ │
│  │  └─────────────────────────────────────────────────────────────────────────────┘   │ │
│  └─────────────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                            │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐ │
│  │                          Container Registry (ECR)                                  │ │
│  │                                                                                     │ │
│  │  ┌─────────────────────────────────────────────────────────────────────────────┐   │ │
│  │  │                    Docker Image Repository                                  │   │ │
│  │  │                                                                             │   │ │
│  │  │  • Base Image: nginx:alpine                                                 │   │ │
│  │  │  • Custom Content: index.html                                               │   │ │
│  │  │  • Tag: latest                                                              │   │ │
│  │  │  • Port: 80                                                                 │   │ │
│  │  └─────────────────────────────────────────────────────────────────────────────┘   │ │
│  └─────────────────────────────────────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────────────────────────────────┘

                                    ┌─────────────────┐
                                    │                 │
                                    │   Monitoring    │
                                    │   & Logging     │
                                    │                 │
                                    └─────────┬───────┘
                                              │
        ┌─────────────────────────────────────┼─────────────────────────────────────┐
        │                                     │                                     │
        ▼                                     ▼                                     ▼
┌───────────────┐                    ┌───────────────┐                    ┌───────────────┐
│               │                    │               │                    │               │
│  CloudWatch   │                    │      S3       │                    │     SNS       │
│               │                    │               │                    │               │
│ ┌───────────┐ │                    │ ┌───────────┐ │                    │ ┌───────────┐ │
│ │Log Groups │ │                    │ │   Logs    │ │                    │ │   Topic   │ │
│ │Dashboards │ │                    │ │  Bucket   │ │                    │ │Notifications│ │
│ │  Alarms   │ │                    │ │Lifecycle  │ │                    │ │   Email   │ │
│ │  Metrics  │ │                    │ │ Policies  │ │                    │ │           │ │
│ └───────────┘ │                    │ └───────────┘ │                    │ └───────────┘ │
└───────────────┘                    └───────────────┘                    └───────────────┘
```

## IAM Roles and Permissions

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                IAM Security Model                                   │
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                        ECS Task Execution Role                              │   │
│  │                                                                             │   │
│  │  • Role Name: ecsTaskExecutionRole                                          │   │
│  │  • Trusted Entity: ecs-tasks.amazonaws.com                                  │   │
│  │  • Attached Policy: AmazonECSTaskExecutionRolePolicy                        │   │
│  │                                                                             │   │
│  │  Permissions:                                                               │   │
│  │  • Pull images from ECR                                                     │   │
│  │  • Create CloudWatch log groups and streams                                 │   │
│  │  • Retrieve secrets from AWS Secrets Manager (if used)                     │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

## Data Flow and Traffic Patterns

### 1. **User Request Flow**
```
Internet User → CloudFront (HTTPS) → ALB (HTTP) → ECS Tasks (Port 80) → NGINX Container
```

### 2. **Container Deployment Flow**
```
Docker Build → ECR Push → ECS Task Definition → ECS Service → Fargate Tasks
```

### 3. **Monitoring Data Flow**
```
CloudFront → CloudWatch Metrics
CloudFront → S3 Access Logs
CloudWatch Alarms → SNS → Email Notifications
```

### 4. **Health Check Flow**
```
ALB → Target Group Health Checks → ECS Tasks (Port 80) → Container Health Status
```

## Key Configuration Details

### Network Configuration
- **VPC CIDR**: 10.0.0.0/16
- **Subnet 1**: 10.0.0.0/24 (AZ-1)
- **Subnet 2**: 10.0.1.0/24 (AZ-2)
- **Internet Gateway**: Provides internet access
- **Route Table**: Routes 0.0.0.0/0 to Internet Gateway

### Container Specifications
- **Base Image**: nginx:alpine
- **Application**: Static HTML served by NGINX
- **Port**: 80 (HTTP)
- **Resource Allocation**: Configurable CPU/Memory via Terraform variables

### Load Balancer Configuration
- **Type**: Application Load Balancer (Internet-facing)
- **Listener**: Port 80 (HTTP)
- **Target Group**: ECS tasks on port 80
- **Health Check**: HTTP on port 80

### CloudFront Configuration
- **Origin**: ALB DNS name
- **Protocol**: HTTP to origin, HTTPS to users
- **Caching**: Default CloudFront caching behavior
- **Logging**: Access logs stored in S3

### Monitoring Setup
- **CloudWatch**: Metrics, logs, dashboards, and alarms
- **S3**: Log storage with lifecycle policies
- **SNS**: Email notifications for alarm triggers
- **Retention**: 30-day log retention policy

## Security Considerations

1. **Network Security**: Public subnets with controlled security group rules
2. **Container Security**: Minimal NGINX Alpine base image
3. **Access Control**: IAM roles with least privilege principles
4. **Traffic Encryption**: HTTPS via CloudFront, HTTP internally
5. **Monitoring**: CloudWatch alarms for error rate monitoring

## Scalability Features

1. **Auto Scaling**: ECS service can scale tasks based on demand
2. **Multi-AZ**: Tasks distributed across multiple availability zones
3. **Load Balancing**: ALB distributes traffic across healthy tasks
4. **Global Distribution**: CloudFront provides global edge locations
