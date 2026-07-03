#!/bin/bash
set -e
export AWS_PAGER=""
REGION=us-east-1
CLUSTER=my-cluster
STACK=eksctl-$CLUSTER-nodegroup-my-nodes

echo ">> Removing the failed node group stack (disabling termination protection first)..."
if aws cloudformation describe-stacks --stack-name "$STACK" --region "$REGION" >/dev/null 2>&1; then
  aws cloudformation update-termination-protection --stack-name "$STACK" --no-enable-termination-protection --region "$REGION" 2>/dev/null || true
  aws cloudformation delete-stack --stack-name "$STACK" --region "$REGION"
  echo "   waiting for it to delete..."
  aws cloudformation wait stack-delete-complete --stack-name "$STACK" --region "$REGION" 2>/dev/null || true
  echo "   old node group stack removed."
fi

echo ">> Pointing kubectl at the existing control plane..."
aws eks --region "$REGION" update-kubeconfig --name "$CLUSTER"

echo ">> Creating a fresh node group (vCPUs are free now) - ~5-8 min..."
eksctl create nodegroup --cluster "$CLUSTER" --region "$REGION" \
  --name ng-workers --node-type t3.small --nodes 1 --nodes-min 1 --nodes-max 2

kubectl get nodes
echo ">> DONE. Node group ready."
