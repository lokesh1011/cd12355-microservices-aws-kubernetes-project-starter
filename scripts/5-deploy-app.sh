#!/bin/bash
set -e
export AWS_PAGER=""
cd "$(dirname "$0")/.."
kubectl apply -f deployments/configmap.yaml
kubectl apply -f deployments/secret.yaml
kubectl apply -f deployments/coworking.yaml
echo ">> Waiting for the coworking pod..."
kubectl rollout status deployment/coworking --timeout=180s || true
kubectl get pods
kubectl get svc
echo ">> DONE. App deployed."
