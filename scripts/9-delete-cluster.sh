#!/bin/bash
export AWS_PAGER=""
REGION=us-east-1
CLUSTER=my-cluster

STATUS_FILTER="CREATE_COMPLETE UPDATE_COMPLETE ROLLBACK_COMPLETE UPDATE_ROLLBACK_COMPLETE CREATE_FAILED DELETE_FAILED UPDATE_ROLLBACK_FAILED"

list_stacks() {
  aws cloudformation list-stacks --region "$REGION" \
    --stack-status-filter $STATUS_FILTER \
    --query "StackSummaries[?starts_with(StackName, 'eksctl-${CLUSTER}-')].StackName" \
    --output text
}

# 1) Best-effort: remove LoadBalancer service so its ELB is cleaned up.
echo ">> Removing LoadBalancer service (if present)..."
kubectl delete svc coworking --ignore-not-found 2>/dev/null || true

# 2) Turn OFF termination protection on every eksctl stack for this cluster.
for STACK in $(list_stacks); do
  echo ">> Disabling termination protection on $STACK"
  aws cloudformation update-termination-protection \
    --stack-name "$STACK" --no-enable-termination-protection --region "$REGION" || true
done

# 3) Delete the cluster (force, skip pod eviction since we're tearing down).
echo ">> Deleting cluster $CLUSTER ..."
eksctl delete cluster --name "$CLUSTER" --region "$REGION" --force --disable-nodegroup-eviction || true

# 4) If eksctl left any stacks behind, delete them directly.
for STACK in $(list_stacks); do
  echo ">> Force-deleting leftover stack $STACK"
  aws cloudformation delete-stack --stack-name "$STACK" --region "$REGION" || true
done

echo
echo ">> DONE. Confirm with:  aws eks list-clusters --region $REGION"
