project_name       = "terraform-test-arj"
environment        = "dev"
source_repo_name   = "terraform-repo-arj"
source_repo_branch = "main"
create_new_repo    = true
stage_input = [
  { name = "validate", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "ValidateOutput" },
  { name = "plan", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "PlanOutput" },
  { name = "apply-approval", category = "Approval", owner = "AWS", provider = "Manual", input_artifacts = "", output_artifacts = "" },
  { name = "apply", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "ApplyOutput" },
  { name = "destroy-approval", category = "Approval", owner = "AWS", provider = "Manual", input_artifacts = "", output_artifacts = "" },
  { name = "destroy", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "DestroyOutput" }
]
build_projects = ["validate", "plan", "apply", "destroy"]
