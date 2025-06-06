## Step 1 : Create an S3 Bucket
resource "random_id" "random_hex" {
  byte_length = 8
}

resource "aws_s3_bucket" "test_bucket" {
  bucket = format("%s-%s", var.bucket_name, random_id.random_hex.hex)
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

-- ## Step 2: Upload objects to S3 bucket
-- resource "aws_s3_object" "test_upload_bucket" {
--   for_each               = fileset("./images", "**")
--   bucket                 = aws_s3_bucket.test_bucket.id
--   key                    = each.key #name of the object
--   source                 = "${"./images"}/${each.value}"
--   etag                   = filemd5("${"./images"}/${each.value}")
--   server_side_encryption = "AES256"
--   tags = {
--     Name        = "My bucket"
--     Environment = "Dev"
--   }
-- }

-- ## Step 3: Enabled the server side encryption using KMS key
-- resource "aws_kms_key" "s3_bucket_kms_key" {
--   description             = "KMS key for s3 bucket"
--   deletion_window_in_days = 7
--   tags = {
--     name = "KMS key for S3 bucket"
--   }
-- }

-- resource "aws_kms_alias" "s3_bucket_kms_key_alias" {
--   name          = "alias/s3_bucket_kms_key_alias"
--   target_key_id = aws_kms_key.s3_bucket_kms_key.key_id
-- }

-- resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket_encryption_with_kms_key" {
--   bucket = aws_s3_bucket.test_bucket.id

--   rule {
--     apply_server_side_encryption_by_default {
--       kms_master_key_id = aws_kms_key.s3_bucket_kms_key.arn
--       sse_algorithm     = "aws:kms"
--     }
--   }
-- }

-- ## Step 4: Setup READ ONLY policy on s3 bucket

-- # Disable the Block Public Access setting

-- # Enabled public access
-- resource "aws_s3_bucket_public_access_block" "enable_public_access" {
--   bucket = aws_s3_bucket.test_bucket.id

--   block_public_acls       = false
--   block_public_policy     = false
--   ignore_public_acls      = false
--   restrict_public_buckets = false
-- }

-- resource "aws_s3_bucket_policy" "test_bucket_read_policy" {
--   bucket = aws_s3_bucket.test_bucket.id
--   policy = jsonencode({
--     Version = "2012-10-17"
--     Statement = [
--       {
--         Effect    = "Allow"
--         Principal = "*"
--         Action    = "s3:GetObject"
--         Resource  = "${aws_s3_bucket.test_bucket.arn}/*"
--       }
--     ]
--   })

--   depends_on = [aws_s3_bucket_public_access_block.enable_public_access]
-- }

-- ## Step 5: S3 Versioning
-- resource "aws_s3_bucket_versioning" "test_bucket_versioning" {
--   bucket = aws_s3_bucket.test_bucket.id
--   versioning_configuration {
--     status = "Enabled"
--   }
-- }

-- ## Step 6: S3 Lifecycle Rules
-- #After 30 days of becoming noncurrent, the object versions are transitioned to STANDARD_IA for cheaper storage with less frequent access.
-- #After 60 days, they are moved to GLACIER for long-term, archival storage.
-- #After 90 days, these noncurrent object versions are deleted.
-- resource "aws_s3_bucket_lifecycle_configuration" "example" {
--   bucket = aws_s3_bucket.test_bucket.id

--   rule {
--     id = "config"

--     filter {
--       prefix = "config/"
--     }

--     noncurrent_version_expiration {
--       noncurrent_days = 90
--     }

--     noncurrent_version_transition {
--       noncurrent_days = 30
--       storage_class   = "STANDARD_IA"
--     }

--     noncurrent_version_transition {
--       noncurrent_days = 60
--       storage_class   = "GLACIER"
--     }

--     status = "Enabled"
--   }

--   depends_on = [aws_s3_bucket_versioning.test_bucket_versioning]
-- }

-- ## Step 7: S3 Bucket logging
-- # Store the server log generated by another bucket
-- resource "aws_s3_bucket" "log_bucket" {
--   bucket = format("%s-%s", "my-demo-test-logging", random_id.random_hex.hex)
--   tags = {
--     Name        = "My log bucket"
--     Environment = "Dev"
--   }
-- }

-- resource "aws_s3_bucket_logging" "example" {
--   bucket = aws_s3_bucket.test_bucket.id

--   target_bucket = aws_s3_bucket.log_bucket.id
--   target_prefix = "log/"
-- }

-- ## Step 8 : Object locking in s3
-- #This means that once an object is uploaded to the bucket, it cannot be deleted or overwritten for at least 1 day
-- resource "aws_s3_bucket_object_lock_configuration" "example" {
--   bucket = aws_s3_bucket.test_bucket.id

--   rule {
--     default_retention {
--       mode = "COMPLIANCE"
--       days = 1
--     }
--   }
-- }