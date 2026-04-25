########################################
# FRONTEND - OWNERSHIP
########################################
resource "aws_s3_bucket_ownership_controls" "frontend_ownership" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

########################################
# FRONTEND - PUBLIC ACCESS SETTINGS
########################################
resource "aws_s3_bucket_public_access_block" "frontend_block" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false   # ✅ IMPORTANT (fixes your error)
  ignore_public_acls      = false
  restrict_public_buckets = false
}

########################################
# FRONTEND - POLICY (PUBLIC READ)
########################################
resource "aws_s3_bucket_policy" "frontend_policy" {
  bucket = aws_s3_bucket.frontend.id

  depends_on = [
    aws_s3_bucket_public_access_block.frontend_block
  ]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.frontend.arn}/*"
      }
    ]
  })
}

########################################
# FRONTEND - WEBSITE HOSTING
########################################
resource "aws_s3_bucket_website_configuration" "frontend_website" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

########################################
# FRONTEND - VERSIONING
########################################
resource "aws_s3_bucket_versioning" "frontend_versioning" {
  bucket = aws_s3_bucket.frontend.id

  versioning_configuration {
    status = "Enabled"
  }
}

########################################
# FRONTEND - ENCRYPTION
########################################
resource "aws_s3_bucket_server_side_encryption_configuration" "frontend_enc" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

########################################
# CANDIDATE IMAGES BUCKET (PRIVATE)
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
# IMAGES - OWNERSHIP
########################################
resource "aws_s3_bucket_ownership_controls" "images_ownership" {
  bucket = aws_s3_bucket.candidate_images.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

########################################
# IMAGES - BLOCK PUBLIC ACCESS (SECURE)
########################################
resource "aws_s3_bucket_public_access_block" "images_block" {
  bucket = aws_s3_bucket.candidate_images.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

########################################
# IMAGES - VERSIONING
########################################
resource "aws_s3_bucket_versioning" "images_versioning" {
  bucket = aws_s3_bucket.candidate_images.id

  versioning_configuration {
    status = "Enabled"
  }
}

########################################
# IMAGES - ENCRYPTION
########################################
resource "aws_s3_bucket_server_side_encryption_configuration" "images_enc" {
  bucket = aws_s3_bucket.candidate_images.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
