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

  filename      = "${path.module}/../lambdas/vote/vote.zip"

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

# ✅ FIXED ROUTE (with dependency)
resource "aws_apigatewayv2_route" "vote" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /vote"

  target = "integrations/${aws_apigatewayv2_integration.vote.id}"

  depends_on = [
    aws_apigatewayv2_integration.vote
  ]
}

# ✅ ADD THIS (VERY IMPORTANT - STAGE)
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
}

# ✅ ADD THIS (VERY IMPORTANT - PERMISSION)
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.vote.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}
