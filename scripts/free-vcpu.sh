#!/bin/bash
export AWS_PAGER=""
REGION=us-east-1
echo ">> Finding the Ansible EC2 instances (ansible-master / ansible-worker)..."
IDS=$(aws ec2 describe-instances --region $REGION \
  --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values=ansible-*" \
  --query "Reservations[].Instances[].InstanceId" --output text)
echo "   Instances to terminate: $IDS"
if [ -n "$IDS" ]; then
  aws ec2 terminate-instances --region $REGION --instance-ids $IDS >/dev/null
  echo ">> Waiting for them to terminate (frees your vCPUs)..."
  aws ec2 wait instance-terminated --region $REGION --instance-ids $IDS
  echo ">> DONE. vCPUs freed."
else
  echo ">> No ansible instances found (already terminated)."
fi
