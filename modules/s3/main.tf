#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2022 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

provider "aws" {
  alias  = "replication"
  region = "us-east-1"
}

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
  provider      = aws.replication
  bucket_prefix = "${regex("[a-z0-9.-]+", lower(var.project_name))}-replication"
}

resource "aws_s3_bucket_public_access_block" "replication_bucket_access" {
  provider                = aws.replication
  bucket                  = aws_s3_bucket.replication_bucket.id
  ignore_public_acls      = true
  restrict_public_buckets = true
  block_public_acls       = true
  block_public_policy     = true
}

resource "aws_s3_bucket_acl" "replication_bucket_acl" {
  provider = aws.replication
  bucket   = aws_s3_bucket.replication_bucket.id
  acl      = "private"
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
  target_bucket = aws_s3_bucket.replication_bucket.id
  target_prefix = "log/"
}

#Artifact Bucket
resource "aws_s3_bucket" "codepipeline_bucket" {
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

resource "aws_s3_bucket_acl" "codepipeline_bucket_acl" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  acl    = "private"
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
  target_bucket = aws_s3_bucket.codepipeline_bucket.id
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