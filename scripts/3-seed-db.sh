#!/bin/bash
set -e
export AWS_PAGER=""
cd "$(dirname "$0")/.."
echo ">> Installing psql client..."
apt update -y >/dev/null && apt install -y postgresql-client >/dev/null
echo ">> Port-forwarding postgres to localhost:5433..."
kubectl port-forward svc/postgresql-service 5433:5432 >/tmp/pf.log 2>&1 &
PF_PID=$!
sleep 6
export PGPASSWORD=mypassword
for f in db/1_create_tables.sql db/2_seed_users.sql db/3_seed_tokens.sql; do
  echo ">> Loading $f"
  psql -h 127.0.0.1 -U myuser -d mydatabase -p 5433 -f "$f"
done
echo ">> Row counts:"
psql -h 127.0.0.1 -U myuser -d mydatabase -p 5433 -c "SELECT COUNT(*) AS users FROM users;"
psql -h 127.0.0.1 -U myuser -d mydatabase -p 5433 -c "SELECT COUNT(*) AS tokens FROM tokens;"
kill $PF_PID 2>/dev/null || true
echo ">> DONE. Database seeded."
