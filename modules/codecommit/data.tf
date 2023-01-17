#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2023 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

# To be used only in case of an Existing Repository
data "aws_codecommit_repository" "existing_repository" {
  count           = var.create_new_repo ? 0 : 1
  repository_name = var.source_repository_name
}
