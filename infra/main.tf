# ---------------- DYNAMODB ----------------
resource "aws_dynamodb_table" "votes" {
  name         = "${var.project_name}-votes2"
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
  name = "${var.project_name}-lambda-role2"

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
  "dynamodb:Query",
  "logs:CreateLogGroup",
  "logs:CreateLogStream",
  "logs:PutLogEvents"
]
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
# ---------------- COGNITO ----------------
resource "aws_cognito_user_pool" "pool" {
  name = "${var.project_name}-users"

  auto_verified_attributes = ["email"]

  schema {
    name     = "email"
    required = true
    attribute_data_type = "String"
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name         = "${var.project_name}-client"
  user_pool_id = aws_cognito_user_pool.pool.id

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  generate_secret = false
}
# ---------------- API AUTHORIZER ----------------
resource "aws_apigatewayv2_authorizer" "cognito" {
  api_id          = aws_apigatewayv2_api.api.id
  authorizer_type = "JWT"
  name            = "cognito-authorizer"

  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    audience = [aws_cognito_user_pool_client.client.id]
    issuer   = aws_cognito_user_pool.pool.endpoint
  }
}
resource "aws_apigatewayv2_route" "vote" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /vote"

  target = "integrations/${aws_apigatewayv2_integration.vote.id}"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}
# ---------------- S3 FRONTEND ----------------
resource "aws_s3_bucket" "frontend" {
  bucket = "${var.project_name}-frontend"
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls   = false
  block_public_policy = false
}
# ---------------- CLOUDFRONT ----------------
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id   = "s3-origin"
  }

  enabled = true

  default_cache_behavior {
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
