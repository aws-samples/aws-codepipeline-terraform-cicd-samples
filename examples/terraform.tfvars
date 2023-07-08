## CodeCommit repository variables
create_new_repo    = true
source_repo_name   = "terraform-sample-repo"
source_repo_branch = "main"
source_repo_description = "Terraform deployments repository"

project_name       = "tf-validate-project"
environment        = "dev"
# repo_approvers_arn = "arn:aws:sts::123456789012:assumed-role/CodeCommitReview/*" #Update ARN (IAM Role/User/Group) of Approval Members
# repo_approvers_arn = "arn:aws:iam::641026500518:user/laura.pena"
create_new_role    = true
#codepipeline_iam_role_name = <Role name> - Use this to specify the role name to be used by codepipeline if the create_new_role flag is set to false.
stage_input = [
  { name = "validate", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "ValidateOutput" },
  { name = "plan", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = "ValidateOutput", output_artifacts = "PlanOutput" },
  { name = "apply", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "PlanOutput", output_artifacts = "ApplyOutput" },
]
stage_destroy_input = [
  { name = "destroy", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "DestroyOutput" }
]
build_projects = ["validate", "plan", "apply", "destroy"]
