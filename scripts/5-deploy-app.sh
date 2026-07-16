#!/bin/bash
set -e
export AWS_PAGER=""
cd "$(dirname "$0")/.."
ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
IMAGE_URI="$ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/coworking:latest"
echo ">> Setting deployment image to: $IMAGE_URI"
sed -i -E "s|^([[:space:]]*image: ).*|\1$IMAGE_URI|" deployments/coworking.yaml
grep "image:" deployments/coworking.yaml
kubectl apply -f deployments/configmap.yaml
kubectl apply -f deployments/secret.yaml
kubectl apply -f deployments/coworking.yaml
echo ">> Waiting for the coworking pod..."
kubectl rollout status deployment/coworking --timeout=180s || true
kubectl get pods
kubectl get svc
echo ">> DONE. App deployed."
