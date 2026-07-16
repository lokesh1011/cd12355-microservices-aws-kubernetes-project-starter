#!/bin/bash
export AWS_PAGER=""
REGION=us-east-1
PROJECT=coworking

# Create a webhook so that pushing to the GitHub repo automatically starts a build.
echo ">> Creating a PUSH webhook on CodeBuild project '$PROJECT'..."
aws codebuild create-webhook \
  --project-name "$PROJECT" \
  --region "$REGION" \
  --filter-groups '[[{"type":"EVENT","pattern":"PUSH"}]]' \
  && echo ">> Webhook created. A git push to the repo will now trigger a build automatically." \
  || echo ">> If it says a webhook already exists, that's fine - it is already enabled."
