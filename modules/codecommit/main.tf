#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2023 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

resource "aws_codecommit_repository" "source_repository" {
  count           = var.create_new_repo ? 1 : 0
  repository_name = var.source_repository_name
  default_branch  = var.source_repository_branch
  description     = "Code Repository for hosting the terraform code and pipeline configuration files"
  tags            = var.tags
}
resource "aws_codecommit_approval_rule_template" "source_repository_approval" {
  count       = var.create_new_repo ? 1 : 0
  name        = "${var.source_repository_name}-${var.source_repository_branch}-Rule"
  description = "Approval rule template for enabling approval process"

  content = <<EOF
{
    "Version": "2018-11-08",
    "DestinationReferences": ["refs/heads/${var.source_repository_branch}"],
    "Statements": [{
        "Type": "Approvers",
        "NumberOfApprovalsNeeded": 2,
        "ApprovalPoolMembers": ["${var.repo_approvers_arn}"]
    }]
}
EOF
}

resource "aws_codecommit_approval_rule_template_association" "source_repository_approval_association" {
  count                       = var.create_new_repo ? 1 : 0
  approval_rule_template_name = aws_codecommit_approval_rule_template.source_repository_approval[0].name
  repository_name             = aws_codecommit_repository.source_repository[0].repository_name
}
