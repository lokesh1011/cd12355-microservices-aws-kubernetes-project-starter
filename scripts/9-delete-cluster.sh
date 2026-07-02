#!/bin/bash
export AWS_PAGER=""
eksctl delete cluster --name my-cluster --region us-east-1
