
resource "aws_s3_bucket" "tfstate" {
  bucket = "realtime-chat-terraform-state"

  tags = {
    Name = "realtime-chat-terraform-state"
  }
}

resource "aws_s3_bucket_ownership_controls" "tfstate_bucket" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "tfstate_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.tfstate_bucket]
  bucket     = aws_s3_bucket.tfstate.id
  acl        = "private"
}

resource "aws_s3_bucket_versioning" "tfstate_bucket_versioning" {
  bucket = aws_s3_bucket.tfstate.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate_bucket_sse" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

output "s3_bucket_name" {
  value = aws_s3_bucket.tfstate.id
}