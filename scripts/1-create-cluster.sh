#!/bin/bash
set -e
export AWS_PAGER=""

echo ">> Upgrading eksctl (the workspace ships an old version that defaults to k8s 1.24)..."
curl -sSL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz" -o /tmp/eksctl.tar.gz
tar -xzf /tmp/eksctl.tar.gz -C /tmp
DEST=$(command -v eksctl || echo /usr/local/bin/eksctl)
mv /tmp/eksctl "$DEST"
echo -n ">> eksctl now: "; eksctl version

echo ">> Cleaning up any failed previous cluster stack (safe if none exists)..."
eksctl delete cluster --name my-cluster --region us-east-1 --wait 2>/dev/null || true

echo ">> Creating EKS cluster on Kubernetes 1.31 (this takes ~15-20 minutes)..."
eksctl create cluster --name my-cluster --region us-east-1 --version 1.31 \
  --nodegroup-name my-nodes --node-type t3.small --nodes 1 --nodes-min 1 --nodes-max 2

echo ">> Updating kubeconfig..."
aws eks --region us-east-1 update-kubeconfig --name my-cluster
kubectl get nodes
echo ">> DONE. Cluster is ready."
