#!/bin/bash
export AWS_PAGER=""
aws ecr create-repository --repository-name coworking --region us-east-1 >/dev/null 2>&1 \
  && echo ">> Created ECR repo 'coworking'" \
  || echo ">> ECR repo 'coworking' already exists (that's fine)"
echo ""
echo ">> Use these values in your CodeBuild environment variables:"
echo "   AWS_ACCOUNT_ID      = $(aws sts get-caller-identity --query Account --output text)"
echo "   AWS_DEFAULT_REGION  = us-east-1"
echo "   IMAGE_REPO_NAME     = coworking"
