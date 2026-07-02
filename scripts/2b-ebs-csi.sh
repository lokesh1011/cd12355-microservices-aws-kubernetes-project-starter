#!/bin/bash
set -e
export AWS_PAGER=""
REGION=us-east-1
CLUSTER=my-cluster
ACCOUNT=$(aws sts get-caller-identity --query Account --output text)

echo ">> Current state (before fix):"
kubectl get pods || true
kubectl get pvc || true

echo ">> Enabling the IAM OIDC provider for the cluster..."
eksctl utils associate-iam-oidc-provider --cluster "$CLUSTER" --region "$REGION" --approve

echo ">> Creating the IAM role for the EBS CSI driver..."
eksctl create iamserviceaccount \
  --name ebs-csi-controller-sa --namespace kube-system \
  --cluster "$CLUSTER" --region "$REGION" \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve --role-only --role-name AmazonEKS_EBS_CSI_DriverRole

echo ">> Installing the aws-ebs-csi-driver add-on..."
eksctl create addon --name aws-ebs-csi-driver --cluster "$CLUSTER" --region "$REGION" \
  --service-account-role-arn "arn:aws:iam::$ACCOUNT:role/AmazonEKS_EBS_CSI_DriverRole" --force

echo ">> Waiting ~30s for the driver, then for the postgres pod..."
sleep 30
kubectl rollout status deployment/postgresql --timeout=300s || true
echo ">> Final state:"
kubectl get pods
kubectl get pvc
echo ">> DONE (postgres should now be Running 1/1)."
