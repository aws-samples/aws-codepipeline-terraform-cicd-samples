# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
output "bucket" {
  value       = aws_s3_bucket.log_bucket.id
  description = "The name of the access log bucket"
}
