# Security Policy

## Disclaimer

This repository contains sample code for demonstration and learning. It is **not production-ready**.
Review and test it against your own security, compliance and operational requirements before any
production use. The authors and AWS make no warranty regarding its fitness for production workloads.

## Reporting Vulnerabilities

If you discover a potential security issue in this project we ask that you notify AWS/Amazon Security
via our [vulnerability reporting page](https://aws.amazon.com/security/vulnerability-reporting/).
Please do **not** create a public GitHub issue.

## AWS Services Used

AWS CodePipeline, AWS CodeBuild, AWS CodeCommit, AWS IAM, AWS KMS, Amazon S3 (artifact bucket, replica bucket and
two access log buckets) and Amazon CloudWatch Logs. The build projects run Terraform, checkov and Trivy
on the Amazon Linux 2023 CodeBuild image.

## Prerequisites and Permissions

Deploying the stack with Terraform requires permissions to create IAM roles and policies, KMS keys, S3 buckets
(in two Regions), a CodeCommit repository and approval rule template, CodeBuild projects and a CodePipeline pipeline.

The pipeline role (`<project_name>-codepipeline-role`) is trusted by CodePipeline and CodeBuild. It can read and write
the artifact bucket, use the pipeline KMS key, read the source CodeCommit repository, start the build projects of this
project and write their logs and reports. It has **no permissions to create the resources that your Terraform code
manages**. The `apply` stage fails with `AccessDenied` until you add them to `modules/iam-role/main.tf`.
Grant only what your configuration needs.

The KMS key policy lets the account root manage the key and lets the pipeline role use it (encrypt, decrypt, data keys,
grants for AWS resources). The pipeline role cannot administer the key.

## Known Security Considerations

The following items were reviewed and accepted for this sample. Revisit them before any production use.

| Item | Why it is acceptable here | Production recommendation |
|------|---------------------------|---------------------------|
| The `apply` and `destroy` stages run automatically after `plan`, with no manual approval | The pipeline is meant for a test account that is cleaned up by the `destroy` stage | Add a manual approval action before `apply`, and do not run `destroy` against anything that you want to keep |
| One IAM role is used by CodePipeline and CodeBuild | Keeps the sample small | Use one role for CodePipeline and a separate role for each CodeBuild project, each with its own permissions |
| `kms:*` for the account root in the key policy | Standard default that keeps the key manageable through IAM | Scope key administration to a named role |
| Terraform state is stored in the build workspace and passed as a pipeline artifact | Fine for a short-lived test | Use a remote backend (Amazon S3 with locking) and keep the state out of artifacts |
| The artifact bucket is replicated to a second Region, but objects that use the pipeline KMS key are not replicated | The replication is an example | Add a KMS key in the destination Region and set `sse_kms_encrypted_objects` in the replication rule |
| S3 access logs are not encrypted with KMS | S3 can't deliver access logs to a bucket that uses SSE-KMS | Send logs to a central, locked-down log bucket |
| CodeBuild projects run in the AWS managed network (no VPC) | Keeps the sample small | Run the projects in a VPC with endpoints and egress rules |
| Tool downloads use pinned versions with SHA256 checks, but `checkov` is installed from PyPI | Pinned version, no hash check | Mirror the packages in an internal repository (for example, AWS CodeArtifact) |
| Buckets use `force_destroy = true` | Clean-up with `terraform destroy` works | Remove it for any bucket that holds data you need |

## Operational Notes

- Anyone who can push to the source repository branch starts a pipeline run that applies Terraform with the pipeline
  role. Restrict who can push to or approve changes on that branch (the sample adds a two-approver rule template).
- The build log and the plan file can contain resource names and values from your Terraform code. Do not put
  secrets in Terraform variables or outputs.
- The CodeBuild projects download Terraform from `releases.hashicorp.com` and Trivy from GitHub. A change to the version
  variables needs a matching SHA256 value, or the build stops.

## Resource Cleanup

Run `terraform destroy --var-file=terraform.tfvars` in the root of this repository. The buckets are emptied and deleted
automatically. The KMS key goes into a 10-day pending deletion period. Delete any resources that your own Terraform
code created and that the `destroy` stage did not remove.

## Dependencies

Terraform, checkov and Trivy are installed by the build specification files at pinned versions.
Update them on a regular schedule and update the SHA256 values together with the versions.
