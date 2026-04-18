########################################
# CANDIDATE IMAGES BUCKET
########################################
resource "aws_s3_bucket" "candidate_images1" {
  bucket        = "${var.project_name}-images"

  # ⚠️ safer than force_destroy = true
  force_destroy = false

  tags = {
    Name        = "${var.project_name}-images"
    Environment = "prod"
  }
}

########################################
# OWNERSHIP CONTROL (IMPORTANT)
########################################
resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.candidate_images.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

########################################
# BLOCK PUBLIC ACCESS (SECURE)
########################################
resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.candidate_images.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls       = true
  restrict_public_buckets  = true
}

########################################
# VERSIONING (SAFE STORAGE)
########################################
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.candidate_images.id

  versioning_configuration {
    status = "Enabled"
  }
}

########################################
# SERVER SIDE ENCRYPTION (SECURITY)
########################################
resource "aws_s3_bucket_server_side_encryption_configuration" "enc" {
  bucket = aws_s3_bucket.candidate_images.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
