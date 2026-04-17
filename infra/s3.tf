resource "aws_s3_bucket" "candidate_images" {
  bucket        = "${var.project_name}-images"
  force_destroy = true

  tags = {
    Name        = "${var.project_name}-images"
    Environment = "dev"
  }
}

# ✅ BLOCK PUBLIC ACCESS (SECURE)
resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.candidate_images.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ✅ VERSIONING (SAFE STORAGE)
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.candidate_images.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ✅ ENCRYPTION (SECURITY)
resource "aws_s3_bucket_server_side_encryption_configuration" "enc" {
  bucket = aws_s3_bucket.candidate_images.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
