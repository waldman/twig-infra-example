output "bucket_name" {
  value = aws_s3_bucket.state.id
}

output "bucket_arn" {
  value = aws_s3_bucket.state.arn
}
