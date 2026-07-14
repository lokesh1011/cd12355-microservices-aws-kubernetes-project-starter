#!/bin/bash
export AWS_PAGER=""

echo "===== kubectl get pods =====";                          kubectl get pods
echo; echo "===== kubectl get svc =====";                     kubectl get svc
echo; echo "===== kubectl describe svc postgresql-service ====="; kubectl describe svc postgresql-service
echo; echo "===== kubectl describe deployment coworking ====="; kubectl describe deployment coworking

echo; echo "===== app logs (last 20) ====="
kubectl logs deployment/coworking --tail=20

# Auto-discover the LoadBalancer hostname (no typing needed).
URL=$(kubectl get svc coworking -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo; echo "===== LoadBalancer URL ====="
echo "http://$URL:5153"

if [ -z "$URL" ]; then
  echo "No external hostname yet - the ELB is still provisioning. Re-run this script in ~2 minutes."
  exit 0
fi

# The ELB DNS can take a couple minutes to answer; retry a few times.
echo; echo "===== curl /health_check ====="
for i in 1 2 3 4 5 6; do
  if curl -s -m 10 "http://$URL:5153/health_check"; then echo; break; fi
  echo "  (attempt $i: not reachable yet, waiting 20s...)"; sleep 20
done

echo; echo "===== curl /api/reports/daily_usage ====="
curl -s -m 15 "http://$URL:5153/api/reports/daily_usage"; echo
echo; echo "===== curl /api/reports/user_visits ====="
curl -s -m 15 "http://$URL:5153/api/reports/user_visits"; echo
