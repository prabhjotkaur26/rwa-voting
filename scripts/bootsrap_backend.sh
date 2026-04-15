#!/bin/bash

aws s3api create-bucket --bucket rwa-terraform-state-123 --region ap-south-1

aws s3api put-bucket-versioning \
  --bucket rwa-terraform-state-123 \
  --versioning-configuration Status=Enabled

aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
