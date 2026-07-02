# Coworking Space Analytics — Build & Deploy

## Overview
The Coworking Analytics API is a Flask microservice that reports user check-in
statistics from a PostgreSQL database. This repository contains everything needed
to build the service into a container image and run it on Amazon EKS.

## Architecture & technologies
- **Application** — Python/Flask (`analytics/`), served on port **5153**, backed by PostgreSQL.
- **Build** — AWS **CodeBuild** reads `buildspec.yaml`, builds `analytics/Dockerfile`, and pushes a versioned image to Amazon **ECR**.
- **Runtime** — Amazon **EKS** runs the app plus a PostgreSQL pod; configuration is injected via a **ConfigMap** (non-secret) and a **Secret** (DB password).
- **Observability** — **CloudWatch Container Insights** collects cluster and application logs.

## How the pipeline works
When code is pushed, CodeBuild logs in to ECR, builds the Docker image, tags it
`1.0.$CODEBUILD_BUILD_NUMBER` (semantic versioning), and pushes it to ECR. EKS then
runs that image via `deployment/coworking.yaml`, which pulls plaintext settings from
`deployment/configmap.yaml` and the database password from `deployment/secret.yaml`.
The database runs from `deployment/postgresql-*.yaml`, with data persisted through a
PersistentVolumeClaim.

## Deploying from scratch
Apply the manifests with `kubectl apply -f deployment/` (Postgres storage/service,
ConfigMap/Secret, then the app). The seed data in `db/` is loaded into Postgres once,
and the public URL is read from `kubectl get svc coworking`.

## Releasing a new build
Push your changes in `analytics/` to trigger a CodeBuild run, which publishes a new
`1.0.N` image to ECR. Then bump the `image:` tag in `deployment/coworking.yaml` and run
`kubectl apply -f deployment/coworking.yaml`; EKS performs a rolling update, which you
can confirm with `kubectl get pods` and the `/health_check` endpoint.

---

## Stand-out suggestions

**Resource allocation.** The deployment requests `250m` CPU / `256Mi` memory and caps
at `500m` CPU / `512Mi`, which fits this lightweight Flask workload while protecting the
node from runaway usage.

**Best AWS instance type.** A `t3.small` (2 vCPU, 2 GiB, burstable) is a good fit — the
analytics API is low-traffic and I/O-light, so a burstable general-purpose instance gives
the best price/performance; move to `t3.medium` only if Postgres and extra replicas share
the node.

**Cost savings.** Run a single small node group, delete the cluster with
`eksctl delete cluster` when idle, set CloudWatch log retention (e.g. 7 days), and
lifecycle-expire old ECR images so storage doesn't grow unbounded.
