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

  filename = data.archive_file.auth_zip.output_path

  environment {
    variables = {
      OTP_TABLE    = aws_dynamodb_table.otp.name
      VOTER_TABLE  = aws_dynamodb_table.voters.name
    }
  }
}

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

  filename = data.archive_file.vote_zip.output_path

  environment {
    variables = {
      VOTE_TABLE = aws_dynamodb_table.votes.name
    }
  }
}
