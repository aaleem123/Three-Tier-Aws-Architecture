terraform {
  required_version = ">= 1.6.0"
  required_providers { 
    aws = { source = "hashicorp/aws", version = ">= 5.0" } 
    random = { source = "hashicorp/random", version = ">= 3.5" }
    }
}

provider "aws" { 
  region = var.region 
  }

## Step 1 : Create an S3 Bucket

### Creating unique ID for bucket
resource "random_id" "main_bucket_suffix" {
  byte_length = 8
}

resource "aws_s3_bucket" "three_tier_bucket" {
  bucket = lower(format("%s-%s", var.bucket_name, random_id.main_bucket_suffix.id))
  object_lock_enabled = true

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

# ### Bulk upload of our project files into S3
# resource "aws_s3_object" "test_upload_bucket" {
#   for_each = fileset("${path.module}/images", "**")

#   bucket   = aws_s3_bucket.three_tier_bucket.id
#   key      = each.value
#   source   = "${path.module}/images/${each.value}"
#   etag     = filemd5("${path.module}/images/${each.value}")

#   tags = {
#     Name        = "Uploaded object"
#     Environment = "Dev"
#   }
# }


#### KMS Keys, Alias, Encryption, Block Public Access, Create Policy who can access, Versioning, Lifecycle rules
resource "aws_kms_key" "three_tier_app_key" {
  description = "Kms key for 3 tier app"
  deletion_window_in_days = 7
  tags = {
    name = "Kms key for s3 bucket"
  }  
}


resource "aws_kms_alias" "three_tier_app_alias" {
  name = "alias/three_tier_app_alias"
  target_key_id = aws_kms_key.three_tier_app_key.id
}

resource "aws_s3_bucket_server_side_encryption_configuration" "three_tier_app_kms_encryption" {
  bucket = aws_s3_bucket.three_tier_bucket.id
 
  rule { 
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.three_tier_app_key.arn
      sse_algorithm = "aws:kms"  
    }
  }
}

resource "aws_s3_bucket_public_access_block" "three_tier_bucket_pub" {
  bucket = aws_s3_bucket.three_tier_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "tf_backend_bucket_policy" {
  bucket = aws_s3_bucket.three_tier_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid: "AllowTerraformUserAccess",
        Effect: "Allow",
        Principal = {
          AWS = "arn:aws:iam::682475225405:user/terraform-mainuser"
        },
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Resource = [
          aws_s3_bucket.three_tier_bucket.arn,
          "${aws_s3_bucket.three_tier_bucket.arn}/*"
        ]
      },
      {
        Sid: "DenyInsecureTransport",
        Effect: "Deny",
        Principal: "*",
        Action: "s3:*",
        Resource = [
          aws_s3_bucket.three_tier_bucket.arn,
          "${aws_s3_bucket.three_tier_bucket.arn}/*"
        ],
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_versioning" "three_tier_bucket_versioning" {
  bucket = aws_s3_bucket.three_tier_bucket.id
  versioning_configuration { 
    status = "Enabled" 
    }
}

## S3 Lifecycle Rules
#After 30 days of becoming noncurrent, the object versions are transitioned to STANDARD_IA for cheaper storage with less frequent access.
#After 60 days, they are moved to GLACIER for long-term, archival storage.
#After 90 days, these noncurrent object versions are deleted.
resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle_policy" {
  bucket = aws_s3_bucket.three_tier_bucket.id

  rule {
    id = "config"
    status = "Enabled"

    filter {
      prefix = "config/"
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 60
      storage_class   = "GLACIER"
    }
  }

  depends_on = [aws_s3_bucket_versioning.three_tier_bucket_versioning]
}

###Create another S3 bucket for storing logs of our main bucket

resource "random_id" "log_bucket_suffix" {
  byte_length = 8
}

resource "aws_s3_bucket" "log_bucket" {
  bucket = lower(format("%s-%s", var.bucket_logs, random_id.log_bucket_suffix.id))

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "My logging bucket"
    Environment = "Dev"
  }
}

# # S3 access logging requires ACLs on the TARGET bucket
# resource "aws_s3_bucket_acl" "log_bucket_acl" {
#   bucket = aws_s3_bucket.log_bucket.id
#   acl    = "log-delivery-write"
# }


resource "aws_s3_bucket_public_access_block" "log_bucket_pub" {
  bucket = aws_s3_bucket.log_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_logging" "logging_bucket_connection" {
  bucket = aws_s3_bucket.three_tier_bucket.id
  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "log/"
}

## Step 8 : Object locking in s3
#This means that once an object is uploaded to the bucket, it cannot be deleted or overwritten for at least 1 day
resource "aws_s3_bucket_object_lock_configuration" "one_day_locking" {
  bucket = aws_s3_bucket.three_tier_bucket.id

  rule {
    default_retention {
      mode = "COMPLIANCE"
      days = 1
    }
  }

  depends_on = [aws_s3_bucket_versioning.three_tier_bucket_versioning]
}
