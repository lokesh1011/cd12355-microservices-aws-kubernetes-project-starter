#!/bin/bash
set -e
export AWS_PAGER=""
cd "$(dirname "$0")/.."
kubectl apply -f deployment/pvc.yaml
kubectl apply -f deployment/pv.yaml
kubectl apply -f deployment/postgresql-deployment.yaml
kubectl apply -f deployment/postgresql-service.yaml
echo ">> Waiting for the postgres pod to become ready..."
kubectl wait --for=condition=ready pod -l app=postgresql --timeout=180s
kubectl get pods
kubectl get svc
echo ">> DONE. Postgres is running."
