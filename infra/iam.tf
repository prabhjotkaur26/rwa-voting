# -------------------------------
# IAM ROLE FOR LAMBDA
# -------------------------------
resource "aws_iam_role" "lambda_role" {
  name = "lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# -------------------------------
# ATTACH BASIC LAMBDA POLICY (Logs)
# -------------------------------
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# -------------------------------
# CUSTOM POLICY (ALL IN ONE)
# -------------------------------
resource "aws_iam_role_policy" "lambda_custom_policy" {
  name = "lambda-custom-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # ✅ DynamoDB
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:BatchWriteItem"
        ]
        Resource = "*"
      },

      # ✅ S3 (CSV READ + EXPORT)
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::voter-csv-upload-bucket-12345/*",
          "${aws_s3_bucket.candidate_images.arn}/*"
        ]
      },

      # ✅ SES (Email OTP)
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "*"
      }

    ]
  })
}
