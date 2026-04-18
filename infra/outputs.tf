output "api_gateway_url" {
  description = "Base URL of HTTP API Gateway"
  value       = aws_apigatewayv2_api.api.api_endpoint
}

output "frontend_url" {
  value = aws_s3_bucket_website_configuration.frontend.website_endpoint
}

output "frontend_bucket_name" {
  value = aws_s3_bucket.frontend.id
}

output "images_bucket_name" {
  value = aws_s3_bucket.candidate_images.id
}
