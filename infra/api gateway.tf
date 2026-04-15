resource "aws_api_gateway_rest_api" "api" {
  name = "rwa-api"
}

resource "aws_api_gateway_resource" "auth" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "auth"
}

resource "aws_api_gateway_method" "auth_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.auth.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "auth_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.auth.id
  http_method             = aws_api_gateway_method.auth_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.auth.invoke_arn
}

resource "aws_lambda_permission" "apigw_auth" {
  statement_id  = "AllowExecution"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auth.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_api_gateway_deployment" "deploy" {
  depends_on = [aws_api_gateway_integration.auth_lambda]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "prod"
}
resource "aws_api_gateway_resource" "auth_request" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "auth-request"
}

resource "aws_api_gateway_method" "auth_request_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.auth_request.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "auth_request_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.auth_request.id
  http_method             = aws_api_gateway_method.auth_request_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.auth.invoke_arn
}
resource "aws_api_gateway_resource" "auth_verify" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "auth-verify"
}

resource "aws_api_gateway_method" "auth_verify_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.auth_verify.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "auth_verify_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.auth_verify.id
  http_method             = aws_api_gateway_method.auth_verify_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.verify.invoke_arn
}
resource "aws_api_gateway_resource" "vote" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "vote"
}

resource "aws_api_gateway_method" "vote_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.vote.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "vote_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.vote.id
  http_method             = aws_api_gateway_method.vote_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.vote.invoke_arn
}
resource "aws_api_gateway_resource" "admin_results" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "admin-results"
}

resource "aws_api_gateway_method" "admin_results_get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.admin_results.id
  http_method   = "GET"
  authorization = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "admin_results_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.admin_results.id
  http_method             = aws_api_gateway_method.admin_results_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.admin.invoke_arn
}
resource "aws_api_gateway_resource" "admin_export" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "admin-export"
}

resource "aws_api_gateway_method" "admin_export_get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.admin_export.id
  http_method   = "GET"
  authorization = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "admin_export_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.admin_export.id
  http_method             = aws_api_gateway_method.admin_export_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.export.invoke_arn
}
resource "aws_lambda_permission" "apigw_all" {
  statement_id  = "AllowAllInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "*"
  principal     = "apigateway.amazonaws.com"
}
resource "aws_api_gateway_deployment" "deploy" {
  depends_on = [
    aws_api_gateway_integration.auth_request_lambda,
    aws_api_gateway_integration.auth_verify_lambda,
    aws_api_gateway_integration.vote_lambda,
    aws_api_gateway_integration.admin_results_lambda,
    aws_api_gateway_integration.admin_export_lambda
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "prod"
}
