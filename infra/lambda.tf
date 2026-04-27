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
resource "null_resource" "clean_build" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "if (Test-Path build) { Remove-Item -Recurse -Force build }; New-Item -ItemType Directory -Force build"
    interpreter = ["powershell", "-Command"]
  }
}

########################################
# AUTH LAMBDA BUILD
########################################
resource "null_resource" "auth_build" {
  triggers = {
    source_hash = filemd5("${path.module}/../lambdas/auth/index.py")
    requirements_hash = filemd5("${path.module}/../lambdas/auth/requirements.txt")
  }

  provisioner "local-exec" {
    command = <<EOT
      Set-Location ${path.module}/../lambdas/auth
      if (Test-Path package) { Remove-Item -Recurse -Force package }
      New-Item -ItemType Directory -Force package
      pip install -r requirements.txt -t package
      Copy-Item index.py package\
      Set-Location package
      Compress-Archive -Path * -DestinationPath ../../infra/build/auth.zip -Force
    EOT
    interpreter = ["powershell", "-Command"]
  }

  depends_on = [null_resource.clean_build]
}

########################################
# AUTH LAMBDA
########################################
data "archive_file" "auth_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambdas/auth"
  output_path = "${path.module}/build/auth.zip"

  depends_on = [null_resource.auth_build]
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
# VERIFY LAMBDA BUILD
########################################
resource "null_resource" "verify_build" {
  triggers = {
    source_hash = filemd5("${path.module}/../lambdas/verify/index.py")
    requirements_hash = filemd5("${path.module}/../lambdas/verify/requirements.txt")
  }

  provisioner "local-exec" {
    command = <<EOT
      Set-Location ${path.module}/../lambdas/verify
      if (Test-Path package) { Remove-Item -Recurse -Force package }
      New-Item -ItemType Directory -Force package
      pip install -r requirements.txt -t package
      Copy-Item index.py package\
      Set-Location package
      Compress-Archive -Path * -DestinationPath ../../infra/build/verify.zip -Force
    EOT
    interpreter = ["powershell", "-Command"]
  }

  depends_on = [null_resource.clean_build]
}

########################################
# VERIFY LAMBDA
########################################
data "archive_file" "verify_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambdas/verify"
  output_path = "${path.module}/build/verify.zip"

  depends_on = [null_resource.verify_build]
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
# VOTE LAMBDA BUILD
########################################
resource "null_resource" "vote_build" {
  triggers = {
    source_hash = filemd5("${path.module}/../lambdas/vote/index.py")
    requirements_hash = filemd5("${path.module}/../lambdas/vote/requirements.txt")
  }

  provisioner "local-exec" {
    command = <<EOT
      Set-Location ${path.module}/../lambdas/vote
      if (Test-Path package) { Remove-Item -Recurse -Force package }
      New-Item -ItemType Directory -Force package
      pip install -r requirements.txt -t package
      Copy-Item index.py package\
      Copy-Item app.py package\
      Set-Location package
      Compress-Archive -Path * -DestinationPath ../../infra/build/vote.zip -Force
    EOT
    interpreter = ["powershell", "-Command"]
  }

  depends_on = [null_resource.clean_build]
}

########################################
# VOTE LAMBDA
########################################
data "archive_file" "vote_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambdas/vote"
  output_path = "${path.module}/build/vote.zip"

  depends_on = [null_resource.vote_build]
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
# ADMIN LAMBDA BUILD
########################################
resource "null_resource" "admin_build" {
  triggers = {
    source_hash = filemd5("${path.module}/../lambdas/admin/index.py")
    requirements_hash = filemd5("${path.module}/../lambdas/admin/requirements.txt")
  }

  provisioner "local-exec" {
    command = <<EOT
      Set-Location ${path.module}/../lambdas/admin
      if (Test-Path package) { Remove-Item -Recurse -Force package }
      New-Item -ItemType Directory -Force package
      pip install -r requirements.txt -t package
      Copy-Item index.py package\
      Set-Location package
      Compress-Archive -Path * -DestinationPath ../../infra/build/admin.zip -Force
    EOT
    interpreter = ["powershell", "-Command"]
  }

  depends_on = [null_resource.clean_build]
}

########################################
# ADMIN LAMBDA
########################################
data "archive_file" "admin_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambdas/admin"
  output_path = "${path.module}/build/admin.zip"

  depends_on = [null_resource.admin_build]
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
# EXPORT LAMBDA BUILD
########################################
resource "null_resource" "export_build" {
  triggers = {
    source_hash = filemd5("${path.module}/../lambdas/export/index.py")
    requirements_hash = filemd5("${path.module}/../lambdas/export/requirements.txt")
  }

  provisioner "local-exec" {
    command = <<EOT
      Set-Location ${path.module}/../lambdas/export
      if (Test-Path package) { Remove-Item -Recurse -Force package }
      New-Item -ItemType Directory -Force package
      pip install -r requirements.txt -t package
      Copy-Item index.py package\
      Set-Location package
      Compress-Archive -Path * -DestinationPath ../../infra/build/export.zip -Force
    EOT
    interpreter = ["powershell", "-Command"]
  }

  depends_on = [null_resource.clean_build]
}

########################################
# EXPORT LAMBDA
########################################
data "archive_file" "export_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambdas/export"
  output_path = "${path.module}/build/export.zip"

  depends_on = [null_resource.export_build]
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
# DOWNLOAD LAMBDA BUILD
########################################
resource "null_resource" "download_build" {
  triggers = {
    source_hash = filemd5("${path.module}/../lambdas/download/download.py")
    requirements_hash = filemd5("${path.module}/../lambdas/download/requirements.txt")
  }

  provisioner "local-exec" {
    command = <<EOT
      Set-Location ${path.module}/../lambdas/download
      if (Test-Path package) { Remove-Item -Recurse -Force package }
      New-Item -ItemType Directory -Force package
      pip install -r requirements.txt -t package
      Copy-Item download.py package\
      Set-Location package
      Compress-Archive -Path * -DestinationPath ../../infra/build/download.zip -Force
    EOT
    interpreter = ["powershell", "-Command"]
  }

  depends_on = [null_resource.clean_build]
}

########################################
# DOWNLOAD LAMBDA
########################################
data "archive_file" "download_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambdas/download"
  output_path = "${path.module}/build/download.zip"

  depends_on = [null_resource.download_build]
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
# RESULTS LAMBDA BUILD
########################################
resource "null_resource" "results_build" {
  triggers = {
    source_hash = filemd5("${path.module}/../lambdas/results/index.py")
    requirements_hash = filemd5("${path.module}/../lambdas/results/requirements.txt")
  }

  provisioner "local-exec" {
    command = <<EOT
      Set-Location ${path.module}/../lambdas/results
      if (Test-Path package) { Remove-Item -Recurse -Force package }
      New-Item -ItemType Directory -Force package
      pip install -r requirements.txt -t package
      Copy-Item index.py package\
      Set-Location package
      Compress-Archive -Path * -DestinationPath ../../infra/build/results.zip -Force
    EOT
    interpreter = ["powershell", "-Command"]
  }

  depends_on = [null_resource.clean_build]
}

########################################
# RESULTS LAMBDA
########################################
data "archive_file" "results_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambdas/results"
  output_path = "${path.module}/build/results.zip"

  depends_on = [null_resource.results_build]
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

resource "aws_lambda_function" "csv_import" {
  function_name = "csv-import-function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.11"

  filename         = data.archive_file.csv_import_zip.output_path
  source_code_hash = data.archive_file.csv_import_zip.output_base64sha256

  timeout     = 30
  memory_size = 256

  depends_on = [
    aws_dynamodb_table.voter_registry
  ]

  environment {
    variables = {
      VOTER_TABLE = aws_dynamodb_table.voter_registry.name
    }
  }
}

########################################
# S3 TRIGGER FOR CSV IMPORT
########################################
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.csv_import.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.csv_bucket1.arn
}

resource "aws_s3_bucket_notification" "csv_upload" {
  bucket = aws_s3_bucket.csv_bucket1.bucket

  lambda_function {
    lambda_function_arn = aws_lambda_function.csv_import.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ".csv"
  }

  depends_on = [aws_lambda_permission.allow_s3]
}
