# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

resource "aws_iam_role" "replication_s3_role" {
  name = "${var.project_name}-replication-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "replication_s3_policy" {
  name   = "${var.project_name}-replication-policy"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.codepipeline_bucket.arn}"
      ]
    },
    {
      "Action": [
        "s3:GetObjectVersionForReplication",
        "s3:GetObjectVersionAcl",
         "s3:GetObjectVersionTagging"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.codepipeline_bucket.arn}/*"
      ]
    },
    {
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete",
        "s3:ReplicateTags"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.replication_bucket.arn}/*"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "replication_s3_role_attach" {
  role       = aws_iam_role.replication_s3_role.name
  policy_arn = aws_iam_policy.replication_s3_policy.arn
}

#Replication bucket
resource "aws_s3_bucket" "replication_bucket" {
  #checkov:skip=CKV2_AWS_62:Event notifications are not required for this sample
  provider      = aws.replication
  bucket_prefix = "${regex("[a-z0-9.-]+", lower(var.project_name))}-rpl"
  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_bucket_public_access_block" "replication_bucket_access" {
  provider                = aws.replication
  bucket                  = aws_s3_bucket.replication_bucket.id
  ignore_public_acls      = true
  restrict_public_buckets = true
  block_public_acls       = true
  block_public_policy     = true
}

resource "aws_s3_bucket_policy" "bucket_policy_replication_bucket" {
  provider = aws.replication
  bucket   = aws_s3_bucket.replication_bucket.id
  policy   = data.aws_iam_policy_document.bucket_policy_doc_replication_bucket.json
}

data "aws_iam_policy_document" "bucket_policy_doc_replication_bucket" {
  provider = aws.replication
  statement {
    principals {
      type        = "AWS"
      identifiers = [var.codepipeline_role_arn]
    }

    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:ReplicateObject",
      "s3:PutObject",
      "s3:RestoreObject",
      "s3:PutObjectVersionTagging",
      "s3:PutObjectTagging",
      "s3:PutObjectAcl"
    ]

    resources = [
      aws_s3_bucket.replication_bucket.arn,
      "${aws_s3_bucket.replication_bucket.arn}/*",
    ]
  }
  statement {
    sid       = "DenyInsecureTransport"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.replication_bucket.arn, "${aws_s3_bucket.replication_bucket.arn}/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "replication_bucket_ownership" {
  provider = aws.replication
  bucket   = aws_s3_bucket.replication_bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "replication_bucket_versioning" {
  provider = aws.replication
  bucket   = aws_s3_bucket.replication_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_server_side_encryption_configuration" "replication_bucket_encryption" {
  provider = aws.replication
  bucket   = aws_s3_bucket.replication_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_logging" "replication_bucket_logging" {
  provider      = aws.replication
  bucket        = aws_s3_bucket.replication_bucket.id
  target_bucket = module.replication_access_logs.bucket
  target_prefix = "log/"
}

#Artifact Bucket
resource "aws_s3_bucket" "codepipeline_bucket" {
  #checkov:skip=CKV2_AWS_62:Event notifications are not required for this sample
  bucket_prefix = regex("[a-z0-9.-]+", lower(var.project_name))
  tags          = var.tags
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "codepipeline_bucket_access" {
  bucket                  = aws_s3_bucket.codepipeline_bucket.id
  ignore_public_acls      = true
  restrict_public_buckets = true
  block_public_acls       = true
  block_public_policy     = true
}

resource "aws_s3_bucket_policy" "bucket_policy_codepipeline_bucket" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  policy = data.aws_iam_policy_document.bucket_policy_doc_codepipeline_bucket.json
}

data "aws_iam_policy_document" "bucket_policy_doc_codepipeline_bucket" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [var.codepipeline_role_arn]
    }

    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:ReplicateObject",
      "s3:PutObject",
      "s3:RestoreObject",
      "s3:PutObjectVersionTagging",
      "s3:PutObjectTagging",
      "s3:PutObjectAcl"
    ]

    resources = [
      aws_s3_bucket.codepipeline_bucket.arn,
      "${aws_s3_bucket.codepipeline_bucket.arn}/*",
    ]
  }
  statement {
    sid       = "DenyInsecureTransport"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.codepipeline_bucket.arn, "${aws_s3_bucket.codepipeline_bucket.arn}/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "codepipeline_bucket_ownership" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "codepipeline_bucket_versioning" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_server_side_encryption_configuration" "codepipeline_bucket_encryption" {
  bucket = aws_s3_bucket.codepipeline_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_logging" "codepipeline_bucket_logging" {
  bucket        = aws_s3_bucket.codepipeline_bucket.id
  target_bucket = module.access_logs.bucket
  target_prefix = "log/"
}

resource "aws_s3_bucket_replication_configuration" "replication_config" {
  #provider = aws.replication
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.codepipeline_bucket_versioning]

  role   = aws_iam_role.replication_s3_role.arn
  bucket = aws_s3_bucket.codepipeline_bucket.id

  rule {
    id = "${var.project_name}-replication-rule"

    filter {}

    delete_marker_replication {
      status = "Enabled"
    }

    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.replication_bucket.arn
      storage_class = "STANDARD"
    }
  }
}
resource "aws_s3_bucket_lifecycle_configuration" "codepipeline_bucket_lifecycle" {
  bucket     = aws_s3_bucket.codepipeline_bucket.id
  depends_on = [aws_s3_bucket_versioning.codepipeline_bucket_versioning]
  rule {
    id     = "expire-old-versions"
    status = "Enabled"
    filter {}
    noncurrent_version_expiration {
      noncurrent_days = 30
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "replication_bucket_lifecycle" {
  provider   = aws.replication
  bucket     = aws_s3_bucket.replication_bucket.id
  depends_on = [aws_s3_bucket_versioning.replication_bucket_versioning]
  rule {
    id     = "expire-old-versions"
    status = "Enabled"
    filter {}
    noncurrent_version_expiration {
      noncurrent_days = 30
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Access log buckets. Each log bucket must be in the same Region as the bucket that it logs.
module "access_logs" {
  source            = "../s3-access-logs"
  bucket_prefix     = regex("[a-z0-9.-]+", lower(var.project_name))
  source_bucket_arn = aws_s3_bucket.codepipeline_bucket.arn
  tags              = var.tags
}

module "replication_access_logs" {
  source = "../s3-access-logs"
  providers = {
    aws = aws.replication
  }
  bucket_prefix     = "${regex("[a-z0-9.-]+", lower(var.project_name))}-rpl"
  source_bucket_arn = aws_s3_bucket.replication_bucket.arn
  tags              = var.tags
}
