# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
variable "bucket_prefix" {
  description = "Prefix of the log bucket name"
  type        = string
}

variable "source_bucket_arn" {
  description = "ARN of the bucket whose server access logs are delivered to the log bucket"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to keep the access logs"
  type        = number
  default     = 90
}

variable "tags" {
  description = "Tags to be associated with the log bucket"
  type        = map(any)
  default     = {}
}
