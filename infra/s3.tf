resource "aws_s3_bucket" "candidate_images" {
  bucket = "${var.project_name}-images"

  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "enc" {
  bucket = aws_s3_bucket.candidate_images.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
