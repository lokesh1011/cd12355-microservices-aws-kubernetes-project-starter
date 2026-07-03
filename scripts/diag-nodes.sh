#!/bin/bash
export AWS_PAGER=""
REGION=us-east-1
echo "=== Running EC2 instances (check vCPU usage / leftovers) ==="
aws ec2 describe-instances --region $REGION --filters "Name=instance-state-name,Values=running" \
  --query "Reservations[].Instances[].[InstanceId,InstanceType,Tags[?Key=='Name']|[0].Value]" --output table

echo ""
echo "=== Node group Auto Scaling Group launch activities (the real failure reason) ==="
ASG=$(aws autoscaling describe-auto-scaling-groups --region $REGION \
  --query "AutoScalingGroups[?contains(AutoScalingGroupName,'my-cluster')].AutoScalingGroupName" --output text)
echo "ASG: $ASG"
if [ -n "$ASG" ]; then
  aws autoscaling describe-scaling-activities --region $REGION --auto-scaling-group-name "$ASG" \
    --query "Activities[0:6].[StatusCode,StatusMessage]" --output table
fi

echo ""
echo "=== EKS nodegroup status ==="
aws eks describe-nodegroup --cluster-name my-cluster --nodegroup-name my-nodes --region $REGION \
  --query "nodegroup.{status:status,health:health.issues}" --output json 2>/dev/null || echo "(nodegroup not found)"

echo ""
echo "=== kubectl nodes ==="
kubectl get nodes 2>/dev/null || echo "(no nodes yet)"
