# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.region
}