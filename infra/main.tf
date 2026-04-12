# ---------------- DYNAMODB ----------------
resource "aws_dynamodb_table" "votes" {
  name         = "${var.project_name}-votes1"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "PK"
  range_key = "SK"

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"
}

# ---------------- IAM ROLE ----------------
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role1"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "ddb_policy" {
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:Query"
      ],
      Resource = "*"
    }]
  })
}

# ---------------- LAMBDA ----------------
resource "aws_lambda_function" "vote" {
  function_name = "${var.project_name}-vote"
  runtime       = "python3.11"
  handler       = "app.lambda_handler"

  filename      = "../lambdas/vote/vote.zip"

  role = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.votes.name
    }
  }
}

# ---------------- API GATEWAY ----------------
resource "aws_apigatewayv2_api" "api" {
  name          = "${var.project_name}-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "vote" {
  api_id = aws_apigatewayv2_api.api.id

  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.vote.invoke_arn
}

resource "aws_apigatewayv2_route" "vote" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /vote"

  target = "integrations/${aws_apigatewayv2_integration.vote.id}"
}
