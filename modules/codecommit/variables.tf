#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2023 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

variable "create_new_repo" {
  type        = bool
  description = "Flag for deciding if a new repository needs to be created"
  default     = false
}

variable "source_repository_name" {
  type        = string
  description = "Name of the Source CodeCommit repository used by the pipeline"
}

variable "source_repository_branch" {
  type        = string
  description = "Branch of the Source CodeCommit repository used in pipeline"
}

variable "repo_approvers_arn" {
  description = "ARN or ARN pattern for the IAM User/Role/Group etc that can be used for approving Pull Requests"
  type        = string
}

variable "tags" {
  type        = map(any)
  description = "Tags to be attached to the source CodeCommit repository"
}

variable "kms_key_arn" {
  description = "Name of the project to be prefixed to create the s3 bucket"
  type        = string
}