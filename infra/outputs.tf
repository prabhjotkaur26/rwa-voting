output "api_gateway_url" {
  description = "Base URL of the API Gateway"
  value       = aws_api_gateway_stage.prod.invoke_url
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
