#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2023 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

# Outputs - Dynamic values to be output based on the value of create_new_repo

output "clone_url_http" {
  value       = var.create_new_repo ? aws_codecommit_repository.source_repository[0].clone_url_http : data.aws_codecommit_repository.existing_repository[0].clone_url_http
  description = "List containing the clone url of the CodeCommit repositories"
}

output "repository_name" {
  value       = var.create_new_repo ? aws_codecommit_repository.source_repository[0].repository_name : var.source_repository_name
  description = "List containing the name of the CodeCommit repositories"
}

output "arn" {
  value       = var.create_new_repo ? aws_codecommit_repository.source_repository[0].arn : data.aws_codecommit_repository.existing_repository[0].arn
  description = "LList containing the arn of the CodeCommit repositories"
}
