#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2023 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

output "role_arn" {
  value       = var.create_new_role ? aws_iam_role.codepipeline_role[0].arn : data.aws_iam_role.existing_codepipeline_role[0].arn
  description = "The ARN of the IAM Role"
}

output "role_name" {
  value       = var.create_new_role ? aws_iam_role.codepipeline_role[0].name : data.aws_iam_role.existing_codepipeline_role[0].name
  description = "The ARN of the IAM Role"
}
