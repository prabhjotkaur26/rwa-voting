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
}

# -------------------------------
# S3 Bucket: CSV Upload
# -------------------------------
resource "aws_s3_bucket" "csv_bucket" {
  bucket = "voter-csv-upload-bucket-12345"
}

# -------------------------------
# Lambda ZIP (AUTO BUILD)
# -------------------------------
data "archive_file" "csv_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambdas/csv_import"
  output_path = "${path.module}/build/csv_lambda.zip"
}

# -------------------------------
# Lambda Function
# -------------------------------
resource "aws_lambda_function" "csv_lambda" {
  function_name = "csv_to_dynamodb"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.11"

  filename         = data.archive_file.csv_zip.output_path
  source_code_hash = data.archive_file.csv_zip.output_base64sha256

  timeout = 300
}

# -------------------------------
# Lambda Permission (IMPORTANT)
# -------------------------------
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.csv_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.csv_bucket.arn
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

  depends_on = [aws_lambda_permission.allow_s3]
}

# -------------------------------
# Upload CSV via Terraform
# -------------------------------
resource "aws_s3_object" "voter_csv" {
  bucket = aws_s3_bucket.csv_bucket.id
  key    = "voter.csv"
  source = "${path.module}/voter.csv"

  etag = filemd5("${path.module}/voter.csv")

  depends_on = [aws_s3_bucket_notification.bucket_notify]
}
