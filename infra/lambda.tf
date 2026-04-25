########################################
# COMMON LOCALS
########################################
locals {
  jwt_secret = "CHANGE_THIS_IN_PRODUCTION"
}

# ########################################
# # BUILD DIRECTORY CLEANUP (IMPORTANT)
# ########################################
# resource "null_resource" "clean_build" {
#   triggers = {
#     always_run = timestamp()
#   }

#   provisioner "local-exec" {
#     command = "if exist build rmdir /s /q build && mkdir build"
#     interpreter = ["cmd", "/c"]
#   }
# }
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
    aws_dynamodb_table.voters
  ]

  environment {
    variables = {
      OTP_TABLE    = aws_dynamodb_table.otp.name
      VOTER_TABLE  = aws_dynamodb_table.voters.name
      SENDER_EMAIL = "your-verified-email@example.com"
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
  function_name = "vote-function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.11"

  filename         = data.archive_file.vote_zip.output_path
  source_code_hash = data.archive_file.vote_zip.output_base64sha256

  timeout     = 10
  memory_size = 256

  depends_on = [
    aws_dynamodb_table.votes,
    aws_dynamodb_table.voters
  ]

  environment {
    variables = {
      VOTES_TABLE  = aws_dynamodb_table.votes.name
      VOTER_TABLE  = aws_dynamodb_table.voters.name
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
    aws_dynamodb_table.voters,
    aws_dynamodb_table.election
  ]

  environment {
    variables = {
      VOTE_TABLE   = aws_dynamodb_table.votes.name
      VOTER_TABLE  = aws_dynamodb_table.voters.name
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
  function_name = "results-function"
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
data "archive_file" "csv_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambdas/csv_import.py"
  output_path = "${path.module}/build/csv_import.zip"
}

resource "aws_lambda_function" "csv_import" {
  function_name = "csv-import-function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "csv_import.lambda_handler"
  runtime       = "python3.11"

  filename         = data.archive_file.csv_zip.output_path
  source_code_hash = data.archive_file.csv_zip.output_base64sha256

  timeout     = 15
  memory_size = 256

  depends_on = [
    aws_dynamodb_table.voters
  ]

  environment {
    variables = {
      VOTER_TABLE = aws_dynamodb_table.voters.name
    }
  }
}
  environment {
    variables = {
      VOTE_TABLE   = aws_dynamodb_table.votes.name
      CONFIG_TABLE  = aws_dynamodb_table.election.name
      JWT_SECRET    = "mysecret123"
    }
  }
}
