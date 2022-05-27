# Outputs - Dynamic values to be output based on the value of create_new_role
output "role_arn" {
  value       = var.create_new_role ? aws_iam_role.codepipeline_role[0].arn : data.aws_iam_role.existing_codepipeline_role[0].arn
  description = "The ARN of the IAM Role"
}
