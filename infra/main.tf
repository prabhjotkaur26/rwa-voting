provider "aws" {
  region = "ap-south-1"
}

########################################
# S3 BUCKET: CSV UPLOAD
########################################
resource "aws_s3_bucket" "csv_bucket1" {
  bucket        = "voter-csv-upload-bucket-12345"
  force_destroy = true

  tags = {
    Name        = "csv-upload"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_versioning" "csv_versioning" {
  bucket = aws_s3_bucket.csv_bucket1.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "csv_encrypt" {
  bucket = aws_s3_bucket.csv_bucket1.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
############################################
# ZIP CREATION (TERRAFORM BUILDS ZIP)
############################################
data "archive_file" "csv_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambdas/csv_import"
  output_path = "${path.module}/csv_lambda.zip"
}

resource "aws_lambda_function" "csv_lambda" {
  function_name = "csv_to_dynamodb"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.11"

filename         = data.archive_file.csv_zip.output_path
source_code_hash = data.archive_file.csv_zip.output_base64sha256

  timeout     = 300
  memory_size = 512

  environment {
    variables = {
      VOTER_TABLE = aws_dynamodb_table.voter_registry.name
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic,
    aws_dynamodb_table.voter_registry
  ]
}
########################################
# S3 TRIGGER
########################################
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.csv_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.csv_bucket1.arn
}

resource "aws_s3_bucket_notification" "bucket_notify" {
  bucket = aws_s3_bucket.csv_bucket1.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.csv_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}

########################################
# CSV FILE UPLOAD
########################################
resource "aws_s3_object" "voters_csv" {
  bucket = aws_s3_bucket.csv_bucket1.id
  key    = "voters.csv"

  source = "${path.module}/../voters.csv"

  depends_on = [aws_s3_bucket_notification.bucket_notify]
}

########################################
# FRONTEND BUCKET
########################################
resource "aws_s3_bucket" "frontend" {
  bucket        = "rwa-frontend-bucket-1234"
  force_destroy = true

  tags = {
    Name        = "frontend"
    Environment = "dev"
  }
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

# Public access (for frontend hosting)
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
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.frontend.arn}/*"
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
