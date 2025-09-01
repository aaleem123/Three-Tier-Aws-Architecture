output "bucket_name" {
  value = aws_s3_bucket.three_tier_bucket.bucket
}

output "s3_kms_key_arn" {
  value = aws_kms_key.three_tier_app_key.arn
}
