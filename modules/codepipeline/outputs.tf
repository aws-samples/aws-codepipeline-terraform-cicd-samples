#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2023 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

output "id" {
  value       = aws_codepipeline.terraform_pipeline.id
  description = "The id of the CodePipeline"
}

output "name" {
  value       = aws_codepipeline.terraform_pipeline.name
  description = "The name of the CodePipeline"
}

output "arn" {
  value       = aws_codepipeline.terraform_pipeline.arn
  description = "The arn of the CodePipeline"
}


