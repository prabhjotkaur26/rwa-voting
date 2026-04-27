########################################
# COMMON LOCALS
########################################
locals {
  jwt_secret = "CHANGE_THIS_IN_PRODUCTION"
}

# ########################################
# # BUILD DIRECTORY CLEANUP (IMPORTANT)
# ########################################
# BUILD DIRECTORY CLEANUP
# ########################################
# Using external provisioners can be problematic on Windows. 
# The archive_file data source will handle zip creation automatically.


########################################
# AUTH LAMBDA
########################################
data "archive_file" "auth_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambdas/auth"
  output_path = "${path.module}/build/auth.zip"
}

resource "aws_lambda_function" "auth" {
  function_name = "auth-function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.11"

  filename         = data.archive_file.auth_zip.output_path
  source_code_hash = data.archive_file.auth_zip.output_base64sha256

  timeout     = 10
  memory_size = 256

  depends_on = [
    aws_dynamodb_table.otp,
    aws_dynamodb_table.voter_registry
  ]

  environment {
    variables = {
      OTP_TABLE    = aws_dynamodb_table.otp.name
      VOTER_TABLE  = aws_dynamodb_table.voter_registry.name
      SENDER_EMAIL = "prabh008968@gmail.com"
      JWT_SECRET   = local.jwt_secret
    }
  }
}

########################################
# VERIFY LAMBDA
########################################
data "archive_file" "verify_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambdas/verify"
  output_path = "${path.module}/build/verify.zip"
}

resource "aws_lambda_function" "verify" {
  function_name = "verify-function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.11"

  filename         = data.archive_file.verify_zip.output_path
  source_code_hash = data.archive_file.verify_zip.output_base64sha256

  timeout     = 10
  memory_size = 256

  depends_on = [
    aws_dynamodb_table.otp
  ]

  environment {
    variables = {
      OTP_TABLE  = aws_dynamodb_table.otp.name
      JWT_SECRET  = local.jwt_secret
    }
  }
}

########################################
# VOTE LAMBDA
########################################
data "archive_file" "vote_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambdas/vote"
  output_path = "${path.module}/build/vote.zip"
}

resource "aws_lambda_function" "vote" {
  function_name = "rwa-voting-vote"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.11"

  filename         = data.archive_file.vote_zip.output_path
  source_code_hash = data.archive_file.vote_zip.output_base64sha256

  timeout     = 10
  memory_size = 256

  depends_on = [
    aws_dynamodb_table.votes,
    aws_dynamodb_table.voter_registry
  ]

  environment {
    variables = {
      VOTES_TABLE  = aws_dynamodb_table.votes.name
      VOTER_TABLE  = aws_dynamodb_table.voter_registry.name
      JWT_SECRET   = local.jwt_secret
    }
  }
}

########################################
# ADMIN LAMBDA
########################################
data "archive_file" "admin_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambdas/admin"
  output_path = "${path.module}/build/admin.zip"
}

resource "aws_lambda_function" "admin" {
  function_name = "admin-function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.11"

  filename         = data.archive_file.admin_zip.output_path
  source_code_hash = data.archive_file.admin_zip.output_base64sha256

  timeout     = 10
  memory_size = 256

  depends_on = [
    aws_dynamodb_table.votes,
    aws_dynamodb_table.voter_registry,
    aws_dynamodb_table.election
  ]

  environment {
    variables = {
      VOTE_TABLE   = aws_dynamodb_table.votes.name
      VOTER_TABLE  = aws_dynamodb_table.voter_registry.name
      CONFIG_TABLE = aws_dynamodb_table.election.name
      JWT_SECRET   = local.jwt_secret
    }
  }
}

########################################
# EXPORT LAMBDA
########################################
data "archive_file" "export_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambdas/export"
  output_path = "${path.module}/build/export.zip"
}

resource "aws_lambda_function" "export" {
  function_name = "export-function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.11"

  filename         = data.archive_file.export_zip.output_path
  source_code_hash = data.archive_file.export_zip.output_base64sha256

  timeout     = 15
  memory_size = 512

  depends_on = [
    aws_dynamodb_table.votes,
    aws_dynamodb_table.election,
    aws_s3_bucket.frontend
  ]

  environment {
    variables = {
      VOTE_TABLE   = aws_dynamodb_table.votes.name
      CONFIG_TABLE  = aws_dynamodb_table.election.name
      BUCKET        = aws_s3_bucket.candidate_images.bucket
      JWT_SECRET    = "mysecret123"
    }
  }
}

########################################
# DOWNLOAD LAMBDA
########################################
data "archive_file" "download_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambdas/download"
  output_path = "${path.module}/build/download.zip"
}

resource "aws_lambda_function" "download" {
  function_name = "download-function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "download.lambda_handler"
  runtime       = "python3.11"

  filename         = data.archive_file.download_zip.output_path
  source_code_hash = data.archive_file.download_zip.output_base64sha256

  timeout     = 10
  memory_size = 256

  depends_on = [
    aws_s3_bucket.frontend
  ]

  environment {
    variables = {
      BUCKET = aws_s3_bucket.frontend.bucket
    }
  }
}
########################################
# RESULTS LAMBDA
########################################
data "archive_file" "results_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambdas/results"
  output_path = "${path.module}/build/results.zip"
}

resource "aws_lambda_function" "results" {
  function_name = "getResults"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.11"

  filename         = data.archive_file.results_zip.output_path
  source_code_hash = data.archive_file.results_zip.output_base64sha256

  timeout     = 10
  memory_size = 256

  depends_on = [
    aws_dynamodb_table.votes,
    aws_dynamodb_table.election
  ]

  environment {
    variables = {
      VOTE_TABLE   = aws_dynamodb_table.votes.name
      CONFIG_TABLE = aws_dynamodb_table.election.name
      JWT_SECRET   = "mysecret123"
    }
  }
}

########################################
# CSV IMPORT LAMBDA
########################################
data "archive_file" "csv_import_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambdas/csv_import/index.py"
  output_path = "${path.module}/build/csv_import.zip"
}
