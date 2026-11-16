# AWS CodePipeline CI/CD example

> **Disclaimer:** This is sample code for non-production usage. Work with your security and legal teams to meet your organizational security, regulatory and compliance requirements before deployment. See [SECURITY.md](SECURITY.md) for the services used, permissions, accepted trade-offs and clean-up steps.

Terraform is an infrastructure-as-code (IaC) tool that helps you create, update, and version your infrastructure in a secure and repeatable manner.

The scope of this pattern is to provide a guide and ready to use terraform configurations to setup validation pipelines with end-to-end tests based on AWS CodePipeline, AWS CodeBuild, AWS CodeCommit and Terraform. 

The created pipeline uses the best practices for infrastructure validation and has the below stages

- validate - This stage focuses on terraform IaC validation tools and commands such as terraform validate, terraform fmt -check, checkov and Trivy
- plan - This stage creates an execution plan, which lets you preview the changes that Terraform plans to make to your infrastructure.
- apply - This stage uses the plan created above to provision the infrastructure in the test account.
- destroy - This stage destroys the infrastructure created in the above stage.
Running these four stages ensures the integrity of the terraform configurations.

The `apply` and `destroy` stages run automatically one after the other, so use this pipeline with a test account only.

## Directory Structure
```shell
|-- CODE_OF_CONDUCT.md
|-- CONTRIBUTING.md
|-- LICENSE
|-- README.md
|-- data.tf
|-- examples
|   `-- terraform.tfvars
|-- locals.tf
|-- main.tf
|-- modules
|   |-- codebuild
|   |   |-- README.md
|   |   |-- main.tf
|   |   |-- outputs.tf
|   |   `-- variables.tf
|   |-- codecommit
|   |   |-- README.md
|   |   |-- data.tf
|   |   |-- main.tf
|   |   |-- outputs.tf
|   |   `-- variables.tf
|   |-- codepipeline
|   |   |-- README.md
|   |   |-- main.tf
|   |   |-- outputs.tf
|   |   `-- variables.tf
|   |-- iam-role
|   |   |-- README.md
|   |   |-- data.tf
|   |   |-- main.tf
|   |   |-- outputs.tf
|   |   `-- variables.tf
|   |-- kms
|   |   |-- README.md
|   |   |-- main.tf
|   |   |-- outputs.tf
|   |   `-- variables.tf
|   `-- s3
|       |-- README.md
|       |-- main.tf
|       |-- outputs.tf
|       `-- variables.tf
|-- templates
|   |-- buildspec_apply.yml
|   |-- buildspec_destroy.yml
|   |-- buildspec_plan.yml
|   |-- buildspec_validate.yml
|   `-- scripts
|       `-- tf_ssp_validation.sh
`-- variables.tf

```
## Installation

#### Step 1: Clone this repository.

```shell
git clone https://github.com/aws-samples/aws-codepipeline-terraform-cicd-samples.git
```
Note: If you don't have git installed, [install git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git).


#### Step 2: Update the variables in `examples/terraform.tfvars` based on your requirement. Make sure you are updating the variables project_name, environment, source_repo_name, source_repo_branch, create_new_repo, stage_input and build_projects.

- If you are planning to use an existing terraform CodeCommit repository, then update the variable create_new_repo as **false** and provide the name of your existing repo under the variable source_repo_name
- If you are planning to create new terraform CodeCommit repository, then update the variable create_new_repo as **true** and provide the name of your new repo under the variable source_repo_name

#### Step 3: Update remote backend configuration as required

#### Step 4: Configure the AWS Command Line Interface (AWS CLI) where this IaC is being executed. For more information, see [Configuring the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html).

#### Step 5: Initialize the directory. Run terraform init

#### Step 6: Start a Terraform run using the command terraform apply

Note: Sample terraform.tfvars are available in the examples directory. You may use the below command if you need to provide this sample tfvars as an input to the apply command.
```shell
terraform apply -var-file=./examples/terraform.tfvars
```

## Pre-Requisites

#### Step 1: You would get source_repo_clone_url_http as an output of the installation step. Clone the repository to your local.

git clone <source_repo_clone_url_http>

#### Step 2: Clone this repository.

```shell
git clone https://github.com/aws-samples/aws-codepipeline-terraform-cicd-samples.git
```
Note: If you don't have git installed, [install git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git).

#### Step 3: Copy the templates folder to the AWS CodeCommit sourcecode repository which contains the terraform code to be deployed.
```shell
cd aws-codepipeline-terraform-cicd-samples
cp -r templates $YOUR_CODECOMMIT_REPO_ROOT
```


#### Step 4: Update the variables in the template files with appropriate values and push the same.

#### Step 5: Trigger the pipeline created in the Installation step.
## Tool versions
The build specification files download pinned versions of Terraform, checkov and Trivy. The downloads of Terraform and Trivy are checked against a SHA256 value in the file (`TF_SHA256`, `TRIVY_SHA256`). If you change `TF_VERSION` or `TRIVY_VERSION`, update the matching SHA256 value from the checksum file published with the release.
The default CodeBuild image is `aws/codebuild/amazonlinux-x86_64-standard:5.0` (Amazon Linux 2023).
## Suppressing findings
Suppressions for checkov and Trivy do not conflict. Put the checkov suppression inside the resource block, and put the Trivy suppression on a comment line directly above the resource, or list the Trivy rule IDs in a `.trivyignore` file in the root of your Terraform code:
```hcl
# trivy:ignore:AVD-AWS-0089
resource "aws_s3_bucket" "example" {
  #checkov:skip=CKV_AWS_18:Access logging is not required for this bucket
  bucket_prefix = "example"
}
```
To make failed checks stop the build, set `SKIPVALIDATIONFAILURE` to `"N"` in `templates/buildspec_validate.yml`. The default `"Y"` reports findings but does not fail the stage. Set an `ENABLE_*` variable to `"N"` to turn a check off.
## Pipeline stages and run order
`run_order` in CodePipeline sets the order of **actions inside one stage**, not the order of stages. Stages always run one after the other. In `modules/codepipeline/main.tf` each stage has one action, so the stages run in the order of the `stage_input` list. To run actions in parallel, put several actions in the same stage with the same `run_order`.
## Known limitations
- The artifact bucket is replicated to a second Region as an example. Objects that are encrypted with the pipeline KMS key are not replicated unless you add a KMS key in the destination Region and set `sse_kms_encrypted_objects` in the replication rule.
- The pipeline IAM role only has the permissions that the pipeline itself needs. Add the permissions that your Terraform code needs to `modules/iam-role/main.tf`, or the `apply` stage fails with `AccessDenied`.
- S3 server access logs are written to separate log buckets (one per Region), because S3 can't deliver access logs to a bucket that uses SSE-KMS.

**Note1**: The IAM Role used by the newly created pipeline is very restrictive and follows the Principle of least privilege. Please update the IAM Policy with the required permissions. 
Alternatively, use the _**create_new_role = false**_ option to use an existing IAM role and specify the role name using the variable _**codepipeline_iam_role_name**_

**Note2**: If the **create_new_repo** flag is set to **true**, a new blank repository will be created with the name assigned to the variable **_source_repo_name_**. Since this repository will not be containing the templates folder specified in Step 3 nor any code files, the initial run of the pipeline will be marked as failed in the _Download-Source_ stage itself.

**Note3**: If the **create_new_repo** flag is set to **false** to use an existing repository, ensure the pre-requisite steps specified in step 3 have been done on the target repository.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.73.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_codebuild_terraform"></a> [codebuild\_terraform](#module\_codebuild\_terraform) | ./modules/codebuild | n/a |
| <a name="module_codecommit_infrastructure_source_repo"></a> [codecommit\_infrastructure\_source\_repo](#module\_codecommit\_infrastructure\_source\_repo) | ./modules/codecommit | n/a |
| <a name="module_codepipeline_iam_role"></a> [codepipeline\_iam\_role](#module\_codepipeline\_iam\_role) | ./modules/iam-role | n/a |
| <a name="module_codepipeline_kms"></a> [codepipeline\_kms](#module\_codepipeline\_kms) | ./modules/kms | n/a |
| <a name="module_codepipeline_terraform"></a> [codepipeline\_terraform](#module\_codepipeline\_terraform) | ./modules/codepipeline | n/a |
| <a name="module_s3_artifacts_bucket"></a> [s3\_artifacts\_bucket](#module\_s3\_artifacts\_bucket) | ./modules/s3 | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_build_project_source"></a> [build\_project\_source](#input\_build\_project\_source) | Source and artifacts type of the CodeBuild projects | `string` | `"CODEPIPELINE"` | no |
| <a name="input_build_projects"></a> [build\_projects](#input\_build\_projects) | Names of the CodeBuild projects to create. Each name must match a templates/buildspec\_<name>.yml file | `list(string)` | n/a | yes |
| <a name="input_builder_compute_type"></a> [builder\_compute\_type](#input\_builder\_compute\_type) | Compute type of the CodeBuild projects | `string` | `"BUILD_GENERAL1_SMALL"` | no |
| <a name="input_builder_image"></a> [builder\_image](#input\_builder\_image) | Docker Image to be used by codebuild | `string` | `"aws/codebuild/amazonlinux-x86_64-standard:5.0"` | no |
| <a name="input_builder_image_pull_credentials_type"></a> [builder\_image\_pull\_credentials\_type](#input\_builder\_image\_pull\_credentials\_type) | Image pull credentials type used by codebuild project | `string` | `"CODEBUILD"` | no |
| <a name="input_builder_type"></a> [builder\_type](#input\_builder\_type) | Type of codebuild run environment | `string` | `"LINUX_CONTAINER"` | no |
| <a name="input_codepipeline_iam_role_name"></a> [codepipeline\_iam\_role\_name](#input\_codepipeline\_iam\_role\_name) | Name of the IAM role to be used by the Codepipeline | `string` | `"codepipeline-role"` | no |
| <a name="input_create_new_repo"></a> [create\_new\_repo](#input\_create\_new\_repo) | Whether to create a new repository. Values are true or false. Defaulted to true always. | `bool` | `true` | no |
| <a name="input_create_new_role"></a> [create\_new\_role](#input\_create\_new\_role) | Whether to create a new IAM Role. Values are true or false. Defaulted to true always. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment in which the script is run. Eg: dev, prod, etc | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Unique name for this project | `string` | n/a | yes |
| <a name="input_repo_approvers_arn"></a> [repo\_approvers\_arn](#input\_repo\_approvers\_arn) | ARN or ARN pattern for the IAM User/Role/Group that can be used for approving Pull Requests | `string` | n/a | yes |
| <a name="input_source_repo_branch"></a> [source\_repo\_branch](#input\_source\_repo\_branch) | Default branch in the Source repo for which CodePipeline needs to be configured | `string` | n/a | yes |
| <a name="input_source_repo_name"></a> [source\_repo\_name](#input\_source\_repo\_name) | Source repo name of the CodeCommit repository | `string` | n/a | yes |
| <a name="input_stage_input"></a> [stage\_input](#input\_stage\_input) | List of pipeline stages. Each stage has a name, category, owner, provider, input\_artifacts and output\_artifacts | `list(map(any))` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_codebuild_arn"></a> [codebuild\_arn](#output\_codebuild\_arn) | The ARN of the Codebuild Project |
| <a name="output_codebuild_name"></a> [codebuild\_name](#output\_codebuild\_name) | The Name of the Codebuild Project |
| <a name="output_codecommit_arn"></a> [codecommit\_arn](#output\_codecommit\_arn) | The ARN of the Codecommit repository |
| <a name="output_codecommit_name"></a> [codecommit\_name](#output\_codecommit\_name) | The name of the Codecommit repository |
| <a name="output_codecommit_url"></a> [codecommit\_url](#output\_codecommit\_url) | The Clone URL of the Codecommit repository |
| <a name="output_codepipeline_arn"></a> [codepipeline\_arn](#output\_codepipeline\_arn) | The ARN of the CodePipeline |
| <a name="output_codepipeline_name"></a> [codepipeline\_name](#output\_codepipeline\_name) | The Name of the CodePipeline |
| <a name="output_iam_arn"></a> [iam\_arn](#output\_iam\_arn) | The ARN of the IAM Role used by the CodePipeline |
| <a name="output_kms_arn"></a> [kms\_arn](#output\_kms\_arn) | The ARN of the KMS key used in the codepipeline |
| <a name="output_s3_arn"></a> [s3\_arn](#output\_s3\_arn) | The ARN of the S3 Bucket |
| <a name="output_s3_bucket_name"></a> [s3\_bucket\_name](#output\_s3\_bucket\_name) | The Name of the S3 Bucket |
<!-- END_TF_DOCS -->

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

