variable "source_repository_name" {
  type        = string
  description = "Name of the Source CodeCommit repository"
}

variable "project_name" {
  description = "Unique name for this project"
  type        = string
}

variable "tags" {
  description = "Tags to be attached to the IAM Role"
  type        = map(any)
}