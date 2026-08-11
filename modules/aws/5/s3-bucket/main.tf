locals {
  base_name   = "${var.environment}-${var.class}-${var.component}-${var.module}"
  bucket_name = var.s3_bucket_name != null ? var.s3_bucket_name : local.base_name
}

resource "aws_s3_bucket" "this" {
  bucket        = local.bucket_name
  force_destroy = var.s3_force_destroy

  tags = merge(var.default_tags, {
    Name = local.bucket_name
  })
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.s3_versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
