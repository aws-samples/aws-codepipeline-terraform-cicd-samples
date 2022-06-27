<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_codecommit_approval_rule_template.source_repository_approval](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codecommit_approval_rule_template) | resource |
| [aws_codecommit_approval_rule_template_association.source_repository_approval_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codecommit_approval_rule_template_association) | resource |
| [aws_codecommit_repository.source_repository](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codecommit_repository) | resource |
| [aws_codecommit_repository.existing_repository](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/codecommit_repository) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_new_repo"></a> [create\_new\_repo](#input\_create\_new\_repo) | Flag for deciding if a new repository needs to be created | `bool` | `false` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | Name of the project to be prefixed to create the s3 bucket | `string` | n/a | yes |
| <a name="input_repo_approvers_arn"></a> [repo\_approvers\_arn](#input\_repo\_approvers\_arn) | ARN or ARN pattern for the IAM User/Role/Group etc that can be used for approving Pull Requests | `string` | n/a | yes |
| <a name="input_source_repository_branch"></a> [source\_repository\_branch](#input\_source\_repository\_branch) | Branch of the Source CodeCommit repository used in pipeline | `string` | n/a | yes |
| <a name="input_source_repository_name"></a> [source\_repository\_name](#input\_source\_repository\_name) | Name of the Source CodeCommit repository used by the pipeline | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be attached to the source CodeCommit repository | `map(any)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | LList containing the arn of the CodeCommit repositories |
| <a name="output_clone_url_http"></a> [clone\_url\_http](#output\_clone\_url\_http) | List containing the clone url of the CodeCommit repositories |
| <a name="output_repository_name"></a> [repository\_name](#output\_repository\_name) | List containing the name of the CodeCommit repositories |
<!-- END_TF_DOCS -->