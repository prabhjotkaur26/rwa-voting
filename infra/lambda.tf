# AUTH
data "archive_file" "auth_zip" {
  type        = "zip"
  source_dir  = "../lambdas/auth"
  output_path = "auth.zip"
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
      OTP_TABLE    = aws_dynamodb_table.otp.name
      VOTER_TABLE  = aws_dynamodb_table.voters.name
      SENDER_EMAIL = "prabh008968@gmail.com"
    }
  }
}

# VERIFY
data "archive_file" "verify_zip" {
  type        = "zip"
  source_dir  = "../lambdas/verify"
  output_path = "verify.zip"
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
      OTP_TABLE  = aws_dynamodb_table.otp.name
      JWT_SECRET = "mysecret123"
    }
  }
}

# VOTE
data "archive_file" "vote_zip" {
  type        = "zip"
  source_dir  = "../lambdas/vote"
  output_path = "vote.zip"
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
      VOTE_TABLE = aws_dynamodb_table.votes.name
      VOTER_TABLE  = aws_dynamodb_table.voters.name
      JWT_SECRET = "mysecret123"
    }
  }
}

# ADMIN
data "archive_file" "admin_zip" {
  type        = "zip"
  source_dir  = "../lambdas/admin"
  output_path = "admin.zip"
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
      VOTE_TABLE = aws_dynamodb_table.votes.name
      VOTER_TABLE  = aws_dynamodb_table.voters.name
      CONFIG_TABLE = aws_dynamodb_table.election.name
    }
  }
}
# EXPORT ZIP
data "archive_file" "export_zip" {
  type        = "zip"
  source_dir  = "../lambdas/export"
  output_path = "export.zip"
}
# EXPORT
resource "aws_lambda_function" "export" {
  function_name = "export-function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.11"

  filename         = data.archive_file.export_zip.output_path
  source_code_hash = data.archive_file.export_zip.output_base64sha256

  environment {
    variables = {
      VOTE_TABLE   = aws_dynamodb_table.votes.name
      CONFIG_TABLE = aws_dynamodb_table.election.name
      BUCKET       = aws_s3_bucket.candidate_images.bucket
      JWT_SECRET   = "mysecret123"
    }
  }
}
# RESULTS
data "archive_file" "results_zip" {
  type        = "zip"
  source_dir  = "../lambdas/results"
  output_path = "results.zip"
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
      VOTE_TABLE   = aws_dynamodb_table.votes.name
      CONFIG_TABLE = aws_dynamodb_table.election.name
      JWT_SECRET   = "mysecret123"
    }
  }
}
data "archive_file" "download_zip" {
  type        = "zip"
 source_file = "${path.module}/lambdas/download.py"
  output_path = "${path.module}/download.zip"
}

resource "aws_lambda_function" "download" {
  function_name = "download"
  role          = aws_iam_role.lambda_role.arn

  handler = "download.lambda_handler"
  runtime = "python3.11"

  # ✅ THIS WAS MISSING (MAIN FIX)
  filename         = data.archive_file.download_zip.output_path
  source_code_hash = data.archive_file.download_zip.output_base64sha256

  environment {
    variables = {
      BUCKET = aws_s3_bucket.candidate_images.bucket
    }
  }
}
