project_name       = "terraform_project"
environment        = "dev"
source_repo_name   = "terraform-repo-cicd"
source_repo_branch = "master"
create_new_repo    = true
create_new_role    = true
#codepipeline_iam_role_name = <Role name> - Use this to specify the role name to be used by codepipeline if the create_new_role flag is set to false.
stage_input = [
  { name = "validate", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "ValidateOutput" },
  { name = "plan", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "PlanOutput" },
  { name = "apply-approval", category = "Approval", owner = "AWS", provider = "Manual", input_artifacts = "", output_artifacts = "" },
  { name = "apply", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "ApplyOutput" },
  { name = "destroy-approval", category = "Approval", owner = "AWS", provider = "Manual", input_artifacts = "", output_artifacts = "" },
  { name = "destroy", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "DestroyOutput" }
]
build_projects = ["validate", "plan", "apply", "destroy"]
