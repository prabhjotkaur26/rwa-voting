provider "aws" {
  region = "ap-south-1"
}

# -------------------------------
# DynamoDB: Voter Registry
# -------------------------------
resource "aws_dynamodb_table" "voters1" {
  name         = "rwa-voters"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "email"

  attribute {
    name = "email"
    type = "S"
  }

  tags = {
    Project = "RWA-Voting"
  }
}

# -------------------------------
# DynamoDB: OTP Table
# -------------------------------
resource "aws_dynamodb_table" "otp1" {
  name         = "rwa-otp"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "email"

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
  hash_key     = "post"
  range_key    = "voter"

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
# S3 Bucket: Frontend Hosting
# -------------------------------
resource "aws_s3_bucket" "frontend" {
  bucket = "rwa-frontend-bucket-1234"
}

resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = "*"
      Action = "s3:GetObject"
      Resource = "${aws_s3_bucket.frontend.arn}/*"
    }]
  })
}

# -------------------------------
# SNS Topic (OTP Email)
# -------------------------------
resource "aws_sns_topic" "otp_topic" {
  name = "rwa-otp-topic"
}

# -------------------------------
# S3 Bucket: CSV Upload
# -------------------------------
resource "aws_s3_bucket" "csv_bucket" {
  bucket = "voter-csv-upload-bucket-12345"
}
     
# -------------------------------
# Lambda Function
# -------------------------------
resource "aws_lambda_function" "csv_lambda" {
  filename      = "lambda.zip"
  function_name = "csv_to_dynamodb"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.11"
  timeout       = 300
}

# -------------------------------
# S3 Trigger → Lambda
# -------------------------------
resource "aws_s3_bucket_notification" "bucket_notify" {
  bucket = aws_s3_bucket.csv_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.csv_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }
}
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.csv_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.csv_bucket.arn
}
