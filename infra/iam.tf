resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.lambda_role.id   # 👈 ensure same role used

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # ✅ S3 FIX
      {
        Effect = "Allow"
        Action = ["s3:GetObject"]
        Resource = "arn:aws:s3:::voter-csv-upload-bucket-12345/*"
      },

      # DynamoDB
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:BatchWriteItem"
        ]
        Resource = aws_dynamodb_table.voters1.arn
      },

      # Logs
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

# ✅ CloudWatch Logs
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ✅ Custom Policy (DynamoDB + SES + S3)
resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda-custom-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # 🔹 DynamoDB
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:UpdateItem",
          "dynamodb:Query"
        ]
        Resource = "*"
      },

      # 🔹 SES
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "*"
      },

      # 🔹 S3 (EXPORT FIX)
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.candidate_images.arn}/*"
      }

    ]
  })
}
