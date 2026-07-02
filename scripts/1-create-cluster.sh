#!/bin/bash
set -e
export AWS_PAGER=""
echo ">> Creating EKS cluster (this takes ~15-20 minutes)..."
eksctl create cluster --name my-cluster --region us-east-1 \
  --nodegroup-name my-nodes --node-type t3.small --nodes 1 --nodes-min 1 --nodes-max 2
echo ">> Updating kubeconfig..."
aws eks --region us-east-1 update-kubeconfig --name my-cluster
kubectl get nodes
echo ">> DONE. Cluster is ready."
