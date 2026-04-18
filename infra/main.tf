provider "aws" {
  region = "ap-south-1"
}

########################################
# VOTER REGISTRY TABLE
########################################
resource "aws_dynamodb_table" "voters22" {
  name         = "rwa-voters"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "email"

  attribute {
    name = "email"
    type = "S"
  }

  tags = {
    Name        = "rwa-voters"
    Environment = "prod"
  }
}

########################################
# OTP TABLE (EMAIL OTP)
########################################
resource "aws_dynamodb_table" "otp22" {
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
    Name        = "rwa-otp"
    Environment = "prod"
  }
}

########################################
# VOTES TABLE (SECURE)
########################################
resource "aws_dynamodb_table" "votes22" {
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
    Name        = "rwa-votes"
    Environment = "prod"
  }
}

########################################
# S3 BUCKET: CSV UPLOAD
########################################
resource "aws_s3_bucket" "csv_bucket1" {
  bucket = "voter-csv-upload-bucket-12345"

  tags = {
    Name        = "csv-upload"
    Environment = "prod"
  }
}

resource "aws_s3_bucket_versioning" "csv_versioning" {
  bucket = aws_s3_bucket.csv_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "csv_encrypt" {
  bucket = aws_s3_bucket.csv_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

########################################
# CSV LAMBDA ZIP
########################################
data "archive_file" "csv_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambdas/csv_import"
  output_path = "${path.module}/build/csv_lambda.zip"
}

########################################
# CSV LAMBDA FUNCTION
########################################
resource "aws_lambda_function" "csv_lambda" {
  function_name = "csv_to_dynamodb"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.11"

  filename         = data.archive_file.csv_zip.output_path
  source_code_hash = data.archive_file.csv_zip.output_base64sha256

  timeout     = 300
  memory_size = 512

  tags = {
    Name = "csv-lambda"
  }
}

########################################
# LAMBDA PERMISSION FOR S3
########################################
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.csv_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.csv_bucket.arn
}

########################################
# S3 EVENT TRIGGER
########################################
resource "aws_s3_bucket_notification" "bucket_notify" {
  bucket = aws_s3_bucket.csv_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.csv_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}

########################################
# CSV FILE UPLOAD (OPTIONAL)
########################################
resource "aws_s3_object" "voters_csv" {
  bucket = aws_s3_bucket.csv_bucket.id
  key    = "voters.csv"

  source = "${path.module}/../voters.csv"
  etag   = filemd5("${path.module}/../voters.csv")
}

########################################
# FRONTEND BUCKET
########################################
resource "aws_s3_bucket" "frontend" {
  bucket = "rwa-frontend-bucket-12"

  tags = {
    Name        = "frontend"
    Environment = "prod"
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
