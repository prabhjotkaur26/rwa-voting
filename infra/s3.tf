########################################
# CANDIDATE IMAGES BUCKET
########################################
resource "aws_s3_bucket" "candidate_images" {
  bucket        = "${var.project_name}-images"
  force_destroy = false

  tags = {
    Name        = "${var.project_name}-images"
    Environment = "prod"
  }
}

########################################
# OWNERSHIP CONTROL
########################################
resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.candidate_images.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

########################################
# BLOCK PUBLIC ACCESS
########################################
resource "aws_s3_bucket_public_access_block" "frontend_block" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

########################################
# VERSIONING
########################################
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.candidate_images.id

  versioning_configuration {
    status = "Enabled"
  }
}

########################################
# SERVER SIDE ENCRYPTION
########################################
resource "aws_s3_bucket_server_side_encryption_configuration" "enc" {
  bucket = aws_s3_bucket.candidate_images.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "frontend_policy" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.frontend.arn}/*"
      }
    ]
  })
}
