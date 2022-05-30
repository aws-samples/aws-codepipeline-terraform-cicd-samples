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