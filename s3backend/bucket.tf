data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "s3backend" {
  bucket = var.bucket_Name

  tags = {
    for key, value in var.tags :
    key => value
  }
}

resource "aws_s3_bucket_ownership_controls" "s3backend" {
  bucket = aws_s3_bucket.s3backend.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "s3backend" {
  depends_on = [aws_s3_bucket_ownership_controls.s3backend]

  bucket = aws_s3_bucket.s3backend.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "versioning_s3backend" {
  bucket = aws_s3_bucket.s3backend.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3backend" {
  bucket = aws_s3_bucket.s3backend.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform-bucket-key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_current_account" {
  bucket = aws_s3_bucket.s3backend.id
  policy = data.aws_iam_policy_document.allow_access_from_current_account.json
}

data "aws_iam_policy_document" "allow_access_from_current_account" {
  statement {
  principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket",
        "s3:GetBucketVersioning",
        "s3:PutBucketVersioning"
    ]

    resources = [
      aws_s3_bucket.s3backend.arn,
      "${aws_s3_bucket.s3backend.arn}/*",
    ]
  }
}
