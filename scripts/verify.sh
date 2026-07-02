#!/bin/bash
export AWS_PAGER=""
echo "===== kubectl get svc =====";                        kubectl get svc
echo; echo "===== kubectl get pods =====";                 kubectl get pods
echo; echo "===== kubectl describe svc postgresql-service ====="; kubectl describe svc postgresql-service
echo; echo "===== kubectl describe deployment coworking ====="; kubectl describe deployment coworking
