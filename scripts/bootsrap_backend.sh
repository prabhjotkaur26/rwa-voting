#!/bin/bash
set -e

BUCKET="rwa-terraform-state-123"
TABLE="terraform-locks"
REGION="ap-south-1"

echo "🚀 Bootstrapping Terraform backend..."

# -----------------------------
# CREATE S3 BUCKET (SAFE)
# -----------------------------
if aws s3api head-bucket --bucket $BUCKET 2>/dev/null; then
  echo "✔ S3 bucket already exists"
else
  echo "Creating S3 bucket..."
  aws s3api create-bucket \
    --bucket $BUCKET \
    --region $REGION \
    --create-bucket-configuration LocationConstraint=$REGION
fi

# -----------------------------
# ENABLE VERSIONING
# -----------------------------
aws s3api put-bucket-versioning \
  --bucket $BUCKET \
  --versioning-configuration Status=Enabled

# -----------------------------
# ENABLE ENCRYPTION
# -----------------------------
aws s3api put-bucket-encryption \
  --bucket $BUCKET \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }
    ]
  }'

echo "✔ S3 configured"

# -----------------------------
# CREATE DYNAMODB LOCK TABLE SAFELY
# -----------------------------
if aws dynamodb describe-table --table-name $TABLE --region $REGION >/dev/null 2>&1; then
  echo "✔ DynamoDB table already exists"
else
  echo "Creating DynamoDB lock table..."
  aws dynamodb create-table \
    --table-name $TABLE \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region $REGION

  echo "Waiting for table to become active..."
  aws dynamodb wait table-exists --table-name $TABLE --region $REGION
fi

echo "🎉 Terraform backend ready!"
