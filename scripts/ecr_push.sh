#!/bin/bash
REPO_NAME=n8n-ecs
ACCOUNT_ID=$(aws sts get-caller-identity --profile kevinmun-admin --query Account --output text)
REGION=ap-southeast-5

aws ecr get-login-password --profile kevinmun-admin --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

docker build -t $REPO_NAME ./docker
docker tag $REPO_NAME:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:latest
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:latest
