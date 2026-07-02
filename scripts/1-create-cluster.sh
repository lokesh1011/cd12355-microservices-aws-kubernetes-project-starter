#!/bin/bash
set -e
export AWS_PAGER=""
REGION=us-east-1
CLUSTER=my-cluster

echo ">> Upgrading eksctl (workspace ships an old version that defaults to k8s 1.24)..."
curl -sSL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz" -o /tmp/eksctl.tar.gz
tar -xzf /tmp/eksctl.tar.gz -C /tmp
DEST=$(command -v eksctl || echo /usr/local/bin/eksctl)
mv /tmp/eksctl "$DEST"
echo -n ">> eksctl now: "; eksctl version

echo ">> Deleting any leftover CloudFormation stacks from failed attempts..."
for stack in eksctl-$CLUSTER-nodegroup-my-nodes eksctl-$CLUSTER-cluster; do
  if aws cloudformation describe-stacks --stack-name "$stack" --region "$REGION" >/dev/null 2>&1; then
    echo "   deleting $stack ..."
    aws cloudformation delete-stack --stack-name "$stack" --region "$REGION"
    aws cloudformation wait stack-delete-complete --stack-name "$stack" --region "$REGION" 2>/dev/null || true
    echo "   deleted $stack"
  fi
done

echo ">> Creating EKS cluster on Kubernetes 1.31 (this takes ~15-20 minutes)..."
eksctl create cluster --name "$CLUSTER" --region "$REGION" --version 1.31 \
  --nodegroup-name my-nodes --node-type t3.small --nodes 1 --nodes-min 1 --nodes-max 2

echo ">> Updating kubeconfig..."
aws eks --region "$REGION" update-kubeconfig --name "$CLUSTER"
kubectl get nodes
echo ">> DONE. Cluster is ready."
