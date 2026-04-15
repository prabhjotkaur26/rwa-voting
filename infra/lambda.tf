data "archive_file" "export_zip" {
  type        = "zip"
  source_dir  = "../lambdas/export"
  output_path = "${path.module}/export.zip"
}

resource "aws_lambda_function" "export" {
  function_name = "export-function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.11"

  filename         = data.archive_file.export_zip.output_path
  source_code_hash = data.archive_file.export_zip.output_base64sha256

  timeout      = 10
  memory_size  = 256

  environment {
    variables = {
      VOTE_TABLE = aws_dynamodb_table.votes.name
      BUCKET     = aws_s3_bucket.candidate_images.bucket
    }
  }

  depends_on = [data.archive_file.export_zip]
}
