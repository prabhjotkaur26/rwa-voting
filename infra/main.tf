provider "aws" {
  region = "ap-south-1"
}

# -------------------------------
# DynamoDB: Voter Registry
# -------------------------------
resource "aws_dynamodb_table" "voters1" {
  name         = "rwa-voters"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "email"

  attribute {
    name = "email"
    type = "S"
  }

  tags = {
    Project = "RWA-Voting"
  }
}

# -------------------------------
# DynamoDB: OTP Table (Email-based)
# -------------------------------
resource "aws_dynamodb_table" "otp1" {
  name         = "rwa-otp"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "email"

  attribute {
    name = "email"
    type = "S"
  }

  ttl {
    attribute_name = "expiry"
    enabled        = true
  }

  tags = {
    Project = "RWA-Voting"
  }
}

# -------------------------------
# DynamoDB: Votes Table
# -------------------------------
resource "aws_dynamodb_table" "votes1" {
  name         = "rwa-votes"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "post"
  range_key = "voter"

  attribute {
    name = "post"
    type = "S"
  }

  attribute {
    name = "voter"
    type = "S"
  }

  tags = {
    Project = "RWA-Voting"
  }
}

# -------------------------------
# S3 Bucket (Frontend Hosting)
# -------------------------------
resource "aws_s3_bucket" "frontend" {
  bucket = "rwa-frontend-bucket-12345"

  tags = {
    Project = "RWA-Voting"
  }
}

# Enable static website hosting
resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# Public access (for frontend hosting)
resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Bucket policy (public read)
resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.frontend.arn}/*"
      }
    ]
  })
}

# -------------------------------
# SNS Topic (Email OTP)
# -------------------------------
resource "aws_sns_topic" "otp_topic" {
  name = "rwa-otp-topic"

  tags = {
    Project = "RWA-Voting"
  }
}
