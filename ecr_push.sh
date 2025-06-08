#!/bin/bash
REPO_NAME=ecs-ecr-demo
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=us-east-1

aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

docker build -t $REPO_NAME ./docker
docker tag $REPO_NAME:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:latest
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:latest