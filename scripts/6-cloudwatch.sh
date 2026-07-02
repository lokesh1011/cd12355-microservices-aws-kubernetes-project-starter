#!/bin/bash
export AWS_PAGER=""
echo ">> Finding the node instance role..."
NODE_ROLE=$(aws iam list-roles --query "Roles[?contains(RoleName,'my-cluster') && contains(RoleName,'NodeInstanceRole')].RoleName" --output text)
echo "   Node role: $NODE_ROLE"
[ -n "$NODE_ROLE" ] && aws iam attach-role-policy --role-name "$NODE_ROLE" \
  --policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy 2>/dev/null && echo "   Attached CloudWatchAgentServerPolicy"
echo ">> Installing CloudWatch observability add-on..."
aws eks create-addon --cluster-name my-cluster --region us-east-1 \
  --addon-name amazon-cloudwatch-observability 2>/dev/null && echo "   Add-on created" || echo "   (add-on may already exist)"
echo ">> DONE. Logs appear in CloudWatch > Container Insights in a few minutes."
