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

  environment {
    variables = {
      OTP_TABLE    = aws_dynamodb_table.otp1.name
      VOTER_TABLE  = aws_dynamodb_table.voters1.name
      SENDER_EMAIL = "prabh008968@gmail.com"
      JWT_SECRET   = "mysecret123"
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

  environment {
    variables = {
      OTP_TABLE  = aws_dynamodb_table.otp1.name
      JWT_SECRET = "mysecret123"
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
  function_name = "vote-function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.11"

  filename         = data.archive_file.vote_zip.output_path
  source_code_hash = data.archive_file.vote_zip.output_base64sha256

  environment {
    variables = {
      VOTE_TABLE   = aws_dynamodb_table.votes1.name
      VOTER_TABLE  = aws_dynamodb_table.voters1.name
      JWT_SECRET   = "mysecret123"
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

  environment {
    variables = {
      VOTE_TABLE    = aws_dynamodb_table.votes1.name
      VOTER_TABLE   = aws_dynamodb_table.voters1.name
      CONFIG_TABLE  = aws_dynamodb_table.election.name
      JWT_SECRET    = "mysecret123"
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

  environment {
    variables = {
      VOTE_TABLE   = aws_dynamodb_table.votes1.name
      CONFIG_TABLE = aws_dynamodb_table.election.name
      BUCKET       = aws_s3_bucket.frontend.bucket
      JWT_SECRET   = "mysecret123"
    }
  }
}

########################################
# DOWNLOAD LAMBDA
########################################
data "archive_file" "download_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambdas/download/download.py"
  output_path = "${path.module}/build/download.zip"
}

resource "aws_lambda_function" "download" {
  function_name = "download-function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "download.lambda_handler"
  runtime       = "python3.11"

  filename         = data.archive_file.download_zip.output_path
  source_code_hash = data.archive_file.download_zip.output_base64sha256

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
  function_name = "results-function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.11"

  filename         = data.archive_file.results_zip.output_path
  source_code_hash = data.archive_file.results_zip.output_base64sha256

  environment {
    variables = {
      VOTE_TABLE   = aws_dynamodb_table.votes1.name
      CONFIG_TABLE  = aws_dynamodb_table.election.name
      JWT_SECRET    = "mysecret123"
    }
  }
}
