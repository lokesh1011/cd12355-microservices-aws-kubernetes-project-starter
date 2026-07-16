# Submission Screenshots

Evidence that the Coworking Space analytics service was built with CodeBuild,
stored in ECR, deployed to AWS EKS, and monitored with CloudWatch.

| File | What it shows |
|------|---------------|
| `01-kubectl-pods-svc-postgres-service.png` | `kubectl get pods` (coworking + postgresql both `1/1 Running`), `kubectl get svc` (coworking `LoadBalancer` with EXTERNAL-IP), and `kubectl describe svc postgresql-service`. |
| `02-describe-deployment-coworking.png` | `kubectl describe deployment coworking` — ECR image, resource requests (250m/256Mi) and limits (500m/512Mi), and liveness/readiness probes. |
| `03-deployment-env-events-applogs.png` | Deployment env from ConfigMap + Secret, rollout events, and application logs. |
| `04-app-health-and-daily-usage.png` | `curl /health_check` = `ok` and `/api/reports/daily_usage` returning JSON from the seeded Postgres data. |
| `05-app-user-visits.png` | `/api/reports/user_visits` returning JSON for all seeded users. |
| `06-ecr-image.png` | ECR repository `coworking` with image tags `1.0.1` and `latest`. |
| `07-codebuild-build-succeeded.png` | CodeBuild build history showing a **Succeeded** build. |
| `08-codebuild-project-list.png` | CodeBuild build projects list — `coworking` project, latest build Succeeded. |
| `09-cloudwatch-application-logs.png` | CloudWatch log group `/aws/containerinsights/my-cluster/application` with the `coworking` log stream. |
